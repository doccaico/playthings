package main

import "core:fmt"
import "core:mem"
import "core:os"

import "cp"
import "mv"
import "rm"

USAGE :: `
Usage: cmd-wrapper.exe [cmd] args
  cmd:
    cp: copy a file or directory
    mv: move a file or directory
    rm: remove a file or directory
`

main :: proc() {

	context.allocator = context.temp_allocator
	defer free_all(context.temp_allocator)

	if len(os.args) < 3 {
		fmt.println(USAGE)
		os.exit(1)
	}

	switch (os.args[1]) {
	case "cp":
		cp.run(os.args[2:])
	case "mv":
		mv.run(os.args[2:])
	case "rm":
		rm.run(os.args[2:])
	case:
		fmt.println(USAGE)
		os.exit(1)
	}
}
