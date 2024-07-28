package rm

import "core:c/libc"
import "core:fmt"
import "core:os"
import "core:strings"

USAGE :: `
Usage: rm.exe [options] [src] [dist]	
  Options:
    -h: show a help message
    -r: directory
`

Options :: struct {
	recurse: bool, // -r (for directory)
}

run :: proc(args: []string) {

	opts := Options{}
	files: [dynamic]string

	// fmt.println(args)

	for arg in args {
		if arg[0] == '-' {
			if arg[1] == 'h' {
				fmt.println(USAGE)
				os.exit(1)
			} else if arg[1] == 'r' {
				opts.recurse = true
			} else {
				fmt.println(USAGE)
				os.exit(1)
			}
		} else {
			append(&files, arg)
		}
	}

	if len(files) == 0 {
		fmt.println(USAGE)
		os.exit(1)
	}


	if opts.recurse {
		when ODIN_DEBUG {
			fmt.print("rmdir /s /q ")
			fmt.println(strings.join(files[:], " "))
			os.exit(0)
		}

		command: [dynamic]string
		append(&command, "rmdir /s /q")
		for file in files {
			append(&command, file)
		}
		libc.system(strings.clone_to_cstring(strings.join(command[:], " ")))
	} else {
		when ODIN_DEBUG {
			fmt.print("del ")
			fmt.println(strings.join(files[:], " "))
			os.exit(0)
		}

		command: [dynamic]string
		append(&command, "del")
		for file in files {
			append(&command, file)
		}
		libc.system(strings.clone_to_cstring(strings.join(command[:], " ")))
	}

}
