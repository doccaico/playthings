package main

import "core:fmt"
import "core:strings"

to_bin :: proc(x: int, len: int) -> string {
	assert(len > 0)

	b: strings.Builder
	strings.builder_init_len(&b, len)

	for i := len - 1; i >= 0; i -= 1 {
		strings.write_byte(&b, '1' if (x & (1 << uint(i)) != 0) else '0')
	}

	return strings.to_string(b)
}

main :: proc() {
	{
		n := 27
		ret := to_bin(n, 8)
		fmt.printfln("[M] answer = %s", ret)
		fmt.printfln("[P] answer = %b", n)
	}
	{
		n := 0x8000
		ret := to_bin(n, 16)
		fmt.printfln("[M] answer = %s", ret)
		fmt.printfln("[P] answer = %b", n)
	}
}
