/**
 * Obtiene los tiempos de creación, acceso y modificación de un archivo.
 * @param {String} filePath - La ruta del archivo.
 * @returns {Object} - Un objeto con las propiedades CreationTime, AccessedTime y ModificationTime.
 * @throws {Error} - Si ocurre un error al abrir el archivo o al obtener los tiempos.
 */
GetFileTimes(filePath) {
	oFile := FileOpen(filePath, 0x700)
	DllCall("GetFileTime",
		"Ptr", oFile.Handle,
		"int64*", &creationTime := 0,
		"int64*", &accessedTime := 0,
		"int64*", &modificationTime := 0
	)
	oFile.Close()
	return {
		CreationTime: creationTime,
		AccessedTime: accessedTime,
		ModificationTime: modificationTime
	}
}