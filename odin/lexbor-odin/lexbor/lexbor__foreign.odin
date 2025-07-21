package lexbor

when ODIN_OS == .Windows {
	@(export)
	foreign import lib "windows/lexbor.lib"
}
