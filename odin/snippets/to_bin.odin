package to_bin

import "core:fmt"
import "core:strings"
import "core:testing"

to_bin :: proc(x: int, len: int) -> string {
	assert(len > 0)

	b: strings.Builder
	strings.builder_init_len_cap(&b, 0, len)

	for i := len - 1; i >= 0; i -= 1 {
		strings.write_byte(&b, '1' if (x & (1 << uint(i)) != 0) else '0')
	}

	return strings.to_string(b)
}

@(test)
test_to_bin :: proc(t: ^testing.T) {
	// !!ASSERTS!!
	// {
	// 	s := to_bin(0x0F, 0)
	// 	testing.expect(t, s == "00001111")
	// 	delete(s)
	// }
	{
		s := to_bin(0x0F, 8)
		testing.expect(t, s == "00001111")
		delete(s)
	}
	{
		s := to_bin(0x0F, 12)
		testing.expect(t, s == "000000001111")
		delete(s)
	}
}
