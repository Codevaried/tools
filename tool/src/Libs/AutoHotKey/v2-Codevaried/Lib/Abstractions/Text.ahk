/**
 * Reduce los espacios consecutivos en una cadena a un solo espacio.
 * @param {String} text - El texto en el que se deben comprimir los espacios.
 * @returns {String} - El texto con espacios comprimidos.
 */
CompressSpaces(text) => RegexReplace(text, " {2,}", " ")

/**
 * Azúcar sintáctico. Escribe texto en un archivo.
 * @param {String} whichFile - La ruta al archivo.
 * @param {String} [text=""] - El texto a escribir.
 */
WriteFile(whichFile, text := "") {
	fileObj := FileOpen(whichFile, "w", "UTF-8")
	fileObj.Write(text)
	fileObj.Close()
}

/**
 * Azúcar sintáctico. Agrega texto a un archivo, o lo escribe si el archivo aún no existe.
 * @param {String} whichFile - La ruta al archivo.
 * @param {String} text - El texto a escribir.
 */
AppendFile(whichFile, text) => FileAppend(text, whichFile, "UTF-8")

/**
 * Azúcar sintáctico. Lee un archivo y devuelve el texto contenido en él.
 * @param {String} whichFile - La ruta al archivo a leer.
 * @returns {String} - El texto contenido en el archivo.
 */
ReadFile(whichFile) => FileRead(whichFile, "UTF-8")

/**
 * Intercambia el contenido de dos archivos.
 * El contenido del archivo en path1 ahora estará en path2 y viceversa.
 * @param {String} path1 - La ruta del primer archivo.
 * @param {String} path2 - La ruta del segundo archivo.
 * @throws {Error} - Si ocurre un error al leer o escribir los archivos.
 */
SwitchFiles(path1, path2) {
	file1Read := FileOpen(path1, "r", "UTF-8")
	file2Read := FileOpen(path2, "r", "UTF-8")

	text1 := file1Read.Read()
	text2 := file2Read.Read()

	file1Write := FileOpen(path1, "w", "UTF-8")
	file2Write := FileOpen(path2, "w", "UTF-8")

	file1Write.Write(text2)
	file2Write.Write(text1)

	file1Read.Close()
	file2Read.Close()
	file1Write.Close()
	file2Write.Close()
}