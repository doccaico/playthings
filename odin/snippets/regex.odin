package main

import "core:fmt"
import "core:mem"
import "core:text/regex"

// https://gist.github.com/yelouafi/556e5159e869952335e01f6b473c4ec1

Parse_Error :: union {
	regex.Error,
	Invalid_Error,
}

Invalid_Error :: enum int {
	None,
	Invalid_Integer,
}

parse_integer :: proc(input: string) -> (string, Parse_Error) {
	reg, err := regex.create(`^\d+$`, {})
	if err != nil {
		return "", err
	}
	defer regex.destroy_regex(reg)

	cap, found := regex.match_and_allocate_capture(reg, input)
	defer regex.destroy_capture(cap)

	if found {
		return cap.groups[0], nil
	}

	return "", Invalid_Error.Invalid_Integer
}

main :: proc() {

	when ODIN_DEBUG {
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)

		defer {
			if len(track.allocation_map) > 0 {
				fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
				for _, entry in track.allocation_map {
					fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
				}
			}
			if len(track.bad_free_array) > 0 {
				fmt.eprintf("=== %v incorrect frees: ===\n", len(track.bad_free_array))
				for entry in track.bad_free_array {
					fmt.eprintf("- %p @ %v\n", entry.memory, entry.location)
				}
			}
			mem.tracking_allocator_destroy(&track)
		}
	}

	if ret, err := parse_integer("12"); err != nil {
		switch _ in err {
		case regex.Error:
			panic("failed to create a Regular Expression")
		case Invalid_Error:
			panic("invalid integer")
		case:

		}
	} else {
		fmt.println(ret)
	}
}
