package main

import "core:c/libc"
import "core:encoding/json"
import "core:fmt"
import "core:log"
import "core:mem/virtual"
import "core:os"
import "core:path/filepath"
import "core:strings"

// I've only tested it on Windows.

// Date: 2024/07/23
// Odin version: dev-2024-07-nightly:ef84382
// Run: odin build odin_update.odin -file && .\odin_update.exe (on Windows)

// Required softwares
// Windows: curl, 7za

when ODIN_OS == .Windows { 
	HOME_ENV :: "USERPROFILE"
	SEVEN_ZIP :: "7za"
	OS :: "windows"
	ARCH :: "amd64"
	ODIN_PATH :: `c:\odin`
}

when ODIN_OS == .Linux {
	HOME_ENV :: "HOME"
	SEVEN_ZIP :: "7z"
	OS :: "ubuntu"
	ARCH :: "amd64"
	ODIN_PATH :: `/home/hoge/bin/odin`
}

when  ODIN_OS == .Darwin {
	HOME_ENV :: "HOME"
	SEVEN_ZIP :: "7z"
	OS :: "macos"
	ARCH :: "amd64"
	ODIN_PATH :: `/home/hoge/bin/odin`
}

JSON_URL :: "https://f001.backblazeb2.com/file/odin-binaries/nightly.json"
JSON_NAME :: "nightly.json"

main :: proc() {

	arena: virtual.Arena
	a_err := virtual.arena_init_static(&arena)
	log.assert(a_err == nil, fmt.tprintf("Failed to init memory arena (%s)", a_err))
	arena_allocator := virtual.arena_allocator(&arena)
	defer virtual.arena_destroy(&arena);

	context.allocator = arena_allocator;

	home_dir := os.get_env(HOME_ENV)

	// ~/Downloadsへ移動する
	current_dir_path := strings.join([]string{home_dir, "Downloads"}, filepath.SEPARATOR_STRING)
	os.change_directory(current_dir_path)
	fmt.printf("Changed directory => %s\n", current_dir_path)

	// JSONファイルを保存する
	libc.system("curl -sOL " + JSON_URL)
	fmt.println("The JSON file has been downloaded.")

	// JSONファイルを読み込む
	f, success := os.read_entire_file_from_filename(JSON_NAME)
	if !success {
		log.fatal("Something wrong (os.read_entire_file_from_filename)")
	}

	// JSONファイルをパースする
	j, j_err := json.parse(f)
	if j_err != json.Error.None {
		log.fatal("Something wrong (json.parse)")
	}
	// json.destroy_value(j) // Is this necessary?(- -;;)
	fmt.println("JSON's parsing is done.")

	// "2014-01-01"を取得する
	date := j.(json.Object)["last_updated"].(json.String)[:10]

	// ファイル名を設定する
	filename := fmt.tprintf("odin-%s-%s-nightly%%2B%s.zip", OS, ARCH, date)

	// ダウンロード先のURLを設定する
	dl_url := fmt.tprintf("%s/%s", "https://f001.backblazeb2.com/file/odin-binaries/nightly", filename)

	// ZIPファイルをダウンロードする
	dl_command := strings.clone_to_cstring(strings.join([]string{"curl", "-sOL", dl_url}, " ")) 
	libc.system(dl_command)
	fmt.println("The ZIP file has been downloaded.")

	// ファイルを解凍する
	extraction_command := strings.clone_to_cstring(strings.join([]string{SEVEN_ZIP, "x", "-aoa", filename, ">NUL"}, " "))
	libc.system(extraction_command)
	fmt.println("ZIP's extracting is done.")

	// "c:\odin"を削除する
	libc.system("cmd.exe /c rmdir /q /s " + ODIN_PATH)
	fmt.println("Odin's directory has been removed.")

	// "~/Downloads/dist"を"c:\odin"に移動する
	os.rename("dist", ODIN_PATH)
	fmt.println(`Moved "~/Downloads/dist" to "c:\odin".`)

	// 不必要なファイルを削除する
	os.remove(JSON_NAME)
	os.remove(filename)
	fmt.println("Unnecessary files have been deleted.")
}
