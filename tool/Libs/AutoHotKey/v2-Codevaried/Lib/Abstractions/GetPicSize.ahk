/**
 * Obtiene el tamaño (ancho y alto) de una imagen especificada.
 * @param {String} picturePath - La ruta de la imagen.
 * @returns {Object} - Un objeto con las propiedades Width y Height.
 * @throws {Error} - Si ocurre un error al cargar la biblioteca o la imagen.
 */
GetPicSize(picturePath) {
	hModule := DllCall("LoadLibrary", "Str", "gdiplus")
	si := Buffer(A_PtrSize = 8 ? 24 : 16, 0)
	NumPut("Int", 1, si)
	DllCall("gdiplus\GdiplusStartup", "Ptr*", &pToken := 0, "Ptr", si, "Ptr", 0)
	DllCall("gdiplus\GdipCreateBitmapFromFile", "Str", picturePath, "Ptr*", &pBitmap := 0)
	DllCall("gdiplus\GdipGetImageDimension", "Ptr", pBitmap, "Float*", &w := 0, "Float*", &h := 0)
	DllCall("gdiplus\GdipDisposeImage", "Ptr", pBitmap)
	DllCall("gdiplus\GdiplusShutdown", "Ptr", pToken)
	DllCall("FreeLibrary", "Ptr", hModule)
	return { Width: Round(w), Height: Round(h) }
}