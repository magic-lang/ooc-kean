use draw
include ./stb_image/stb_image
include ./stb_image/stb_image_write

StbImage: class {
	free: extern (stbi_image_free) static func (data: UChar*)
	load: extern (stbi_load) static func (filename: CString, x, y, n: Int*, req_comp: Int) -> UChar*
	writePng: extern (stbi_write_png) static func (filename: const CString, w, h, comp: Int, data: const Pointer, stride_in_bytes: Int) -> Int
	failureReason: extern (stbi_failure_reason) static func -> const CString
}
