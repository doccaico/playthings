package cp

import "core:c/libc"
import "core:fmt"
import "core:os"
import "core:strings"

USAGE :: `
Usage: cp.exe [options] [src] [dist]	
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

	if len(files) != 2 {
		fmt.println(USAGE)
		os.exit(1)
	}

	src := files[0]
	dist := files[1]

	if opts.recurse {
		when ODIN_DEBUG {
			fmt.printf("xcopy /e /c /h %s %s\n", src, dist)
			os.exit(0)
		}
		command := strings.clone_to_cstring(fmt.tprintf("xcopy /e /c /h %s %s", src, dist))
		libc.system(command)
	} else {
		when ODIN_DEBUG {
			fmt.printf("copy %s %s\n", src, dist)
			os.exit(0)
		}
		command := strings.clone_to_cstring(fmt.tprintf("copy %s %s", src, dist))
		libc.system(command)
	}

}
