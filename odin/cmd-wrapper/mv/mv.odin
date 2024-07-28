package mv

import "core:c/libc"
import "core:fmt"
import "core:os"
import "core:strings"

USAGE :: `
Usage: mv.exe [src] [dist]	
`

run :: proc(args: []string) {

	// fmt.println(args)

	if len(args) != 2 {
		fmt.println(USAGE)
		os.exit(1)
	}

	src := args[0]
	dist := args[1]

	when ODIN_DEBUG {
		fmt.printf("move %s %s\n", src, dist)
		os.exit(0)
	}
	command := strings.clone_to_cstring(fmt.tprintf("move %s %s", src, dist))
	libc.system(command)

}
