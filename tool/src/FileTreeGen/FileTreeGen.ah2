#Requires AutoHotkey v2.0
#SingleInstance Force
/*@Ahk2Exe-Keep
#NoTrayIcon
*/

/**
 * ? Archivo principal del script de AutoHotkey v2.
 * * Este script permite generar un árbol de archivos y contenidos de archivos de una carpeta seleccionada.
 * Proporciona una interfaz gráfica (GUI) para seleccionar una carpeta, generar la estructura de directorios
 * y obtener el contenido de los archivos de tipos específicos dentro de esa carpeta.
 * Las funcionalidades principales incluyen:
 *   - Selección de carpetas mediante un diálogo o arrastrando y soltando.
 *   - Generación del árbol de directorios y contenido de archivos.
 *   - Combinación de la estructura de directorios y contenido de archivos en un solo archivo de salida.
 *   - Copia del resultado final al portapapeles para facilitar su uso.
 * 
 * @autor Eloy Navarro Escarabajal
 */


;todo---SECTION: GLOBAL VARIABLES

/**
 * * Nombre del programa. Actualizar con el nombre adecuado.
 * @global {string}
 */
global NAME_PROGRAM := "FileTreeGen (Generación del árbol de archivos)"

/**
 * * Archivos requeridos por el programa.
 * @global {object}
 */
global requiredFiles := {
    extents: "AllowedExtensions.txt", ; Archivo que contiene las extensiones permitidas
}

/**
 * * Archivos temporales utilizados durante la ejecución del programa.
 * @global {object}
 */
global tempFiles := {
    dirTree: generateTempFileName("tree_output"), ; Archivo temporal para el árbol de directorios
    filesContents: generateTempFileName("filesContents_output"), ; Archivo temporal para los contenidos de archivos
    output: "output.tree" ; Archivo de salida combinado
}

/**
 * * Bandera para evitar ejecuciones concurrentes.
 * @global {boolean}
 */
global isGenerating := false


;todo---SECTION: Environment configuration

A_MaxHotkeysPerInterval := 1000
KeyHistory 0
ListLines 0
SetWinDelay 0
SetKeyDelay -1, -1


;todo---SECTION: Development Hotkeys

;! Uso solo para modo desarollo
#HotIf !A_IsCompiled
^s:: {
    Send("^s")  ; Simula Ctrl+S para guardar el archivo
    Sleep(100)  ; Pequeño retraso para asegurar que el archivo se guarde
    Reload()  ; Recarga el script
}
#HotIf


;todo---SECTION: GUI Management

/**
 * * Crear una GUI para generar un árbol de archivos de un directorio arrastrado.
 */
createGui() {
    global NAME_PROGRAM, myGui, folderEdit, folderButton, directoryTreeCheckbox, fileContentsCheckbox, generateText
    myGui := Gui("+AlwaysOnTop", NAME_PROGRAM)
    myGui.SetFont("s10", "Segoe UI")

    ; Añadir controles a la GUI
    myGui.Add("Text", , "Arrastre una carpeta o selecciónela manualmente:")
    folderEdit := myGui.Add("Edit", "w400 vFolderPath")
    folderButton := myGui.Add("Button", "xp+263 y+5", "Seleccionar Carpeta")

    ; Añadir texto "Generate:" con tamaño más grande y ajustar su posición y ancho
    generateText := myGui.Add("Text", "xm yp+10 w100 h23 vGenerateText", "Generate:").SetFont("s12", "Segoe UI")

    ; Añadir CheckBoxes en línea y activarlos por defecto
    directoryTreeCheckbox := myGui.Add("CheckBox", "xm y+5 Checked", "Directory Tree")
    fileContentsCheckbox := myGui.Add("CheckBox", "x+10 Checked", "Files Contents")

    ; Configurar eventos de botones y checkboxes
    folderButton.OnEvent("Click", selectFolder)
    directoryTreeCheckbox.OnEvent("Click", ensureOneCheckboxChecked)
    fileContentsCheckbox.OnEvent("Click", ensureOneCheckboxChecked)

    ; Configurar evento de arrastre
    myGui.OnEvent("DropFiles", guiDropFiles)

    ; Configurar la captura de la tecla Enter
    OnMessage(0x0100, WM_KeyDown)

    ; Configurar el evento de cierre de la GUI para finalizar el programa
    myGui.OnEvent("Close", closeProgram)

    ; Mostrar la GUI centrada
    myGui.Show("AutoSize Center")
}

/**
 * * Maneja el cierre del programa.
 */
closeProgram(*) {
    ExitApp
}

/**
 * * Asegura que al menos uno de los checkboxes esté activado.
 */
ensureOneCheckboxChecked(*) {
    global directoryTreeCheckbox, fileContentsCheckbox
    if (!directoryTreeCheckbox.Value && !fileContentsCheckbox.Value) {
        directoryTreeCheckbox.Value := true
    }
}

/**
 * * Selecciona una carpeta mediante un diálogo y lo mantiene en la parte superior.
 */
selectFolder(*) {
    global folderEdit
    if (checkIfGenerating())
        return

    ; Configurar el temporizador para asegurarse de que el diálogo se mantenga siempre en la parte superior
    SetTimer MakeTopmost, 50

    ; Crear el diálogo de selección de carpeta
    folderPath := FileSelect("D", "", "Seleccione una carpeta")

    ; Desactivar el temporizador después de cerrar el diálogo
    SetTimer MakeTopmost, 0

    ; Verificar si se seleccionó una carpeta
    if (folderPath) {
        folderEdit.Value := normalizePath(folderPath)
        processFolder(folderEdit.Value)
    }

    return
}

/**
 * * Subrutina que establece el diálogo como siempre en la parte superior.
 */
MakeTopmost(*) {
    hwnd := WinExist("Seleccione una carpeta ahk_class #32770")
    if hwnd {
        DllCall("SetWindowPos", "Ptr", hwnd, "Ptr", -1, "Int", 0, "Int", 0, "Int", 0, "Int", 0, "UInt", 0x0003) ; HWND_TOPMOST = -1, SWP_NOMOVE = 0x0002, SWP_NOSIZE = 0x0001
    }
}

/**
 * * Maneja el evento de arrastre de archivos a la GUI.
 * @param {object} thisGui - La GUI donde se soltaron los archivos.
 * @param {object} ctrl - El control donde se soltaron los archivos.
 * @param {array} fileArray - Lista de archivos arrastrados.
 */
guiDropFiles(thisGui, ctrl, fileArray, *) {
    global folderEdit
    if (checkIfGenerating())
        return
    folderPath := normalizePath(fileArray[1])
    if (folderPath) { ; Verificar si la ruta es válida
        folderEdit.Value := folderPath
        processFolder(folderEdit.Value)
    }
}

/**
 * * Maneja el evento de tecla presionada.
 * @param {WPARAM} wParam - El código de la tecla presionada.
 * @param {LPARAM} lParam - Información adicional sobre la tecla presionada.
 * @param {MSG} msg - El mensaje de la tecla presionada.
 * @param {HWND} hwnd - El identificador de la ventana.
 */
WM_KeyDown(wParam, lParam, msg, hwnd) {
    global NAME_PROGRAM, folderEdit
    if (checkIfGenerating())
        return
    if (wParam = 0x0D) { ; Código de la tecla Enter
        if (WinActive(NAME_PROGRAM)) {
            processFolder(folderEdit.Value)
        }
    }
}


;todo---SECTION: Utility Functions

/**
 * * Normaliza una ruta de archivo reemplazando todas las barras "/" con "\" y eliminando cualquier barra inicial o final.
 * @param {string} path - La ruta a normalizar.
 * @return {string} - La ruta normalizada.
 */
normalizePath(path) {
    path := StrReplace(path, "/", "\")
    while (SubStr(path, 1, 1) = "\" or SubStr(path, 1, 1) = "/") {
        path := SubStr(path, 2)
    }
    while (SubStr(path, -1) = "\" or SubStr(path, -1) = "/") {
        path := SubStr(path, 1, -1)
    }
    return validateFolder(path)
}

/**
 * * Valida si una ruta es una carpeta válida.
 * @param {string} path - La ruta a validar.
 * @return {string|false} - La ruta validada si es válida, de lo contrario, false.
 */
validateFolder(path) {
    if (!FileExist(path) or FileExist(path) != "D" and FileExist(path) != "AD" and FileExist(path) != "RD") {
        showTopMsgBox("Ruta de Carpeta Inválida", "Por favor, ingrese una ruta de carpeta válida.", "Error")
        return false
    }
    return path
}

/**
 * * Obtiene el nombre de la carpeta principal de una ruta.
 * @param {string} folderPath - La ruta de la carpeta.
 * @return {string} - El nombre de la carpeta principal.
 */
getMainFolderName(folderPath) {
    originalDir := A_WorkingDir
    SetWorkingDir(folderPath)
    mainFolder := RegExReplace(A_WorkingDir, "^.*\\")
    SetWorkingDir(originalDir)
    return mainFolder
}

/**
 * * Verifica si un valor está en una lista.
 * @param {Array} list - La lista a verificar.
 * @param {string} value - El valor a buscar.
 * @return {boolean} - Verdadero si el valor está en la lista, falso en caso contrario.
 */
hasValue(list, value) {
    for item in list {
        if (item = value)
            return true
    }
    return false
}

/**
 * * Lee las extensiones permitidas desde un archivo.
 * @param {string} filePath - La ruta del archivo que contiene las extensiones permitidas.
 * @return {Array} - Una lista de extensiones permitidas.
 */
loadAllowedExtensions(filePath) {
    if !FileExist(filePath) {
        showTopMsgBox("Archivo de Extensiones No Encontrado", "El archivo de extensiones permitidas no existe. Asegúrese de que '" filePath "' está en el directorio correcto y contiene las extensiones válidas, una por línea.", "Error")
        return []
    }
    extensions := []
    Loop Read, filePath {
        extension := Trim(A_LoopReadLine)
        if (extension != "" && SubStr(extension, 1, 1) != "#") ; Ignorar comentarios y líneas vacías
            extensions.Push(extension)
    }
    return extensions
}

/**
 * * Genera un nombre de archivo temporal aleatorio con un prefijo especificado.
 * @param {string} prefix - El prefijo para el nombre del archivo.
 * @return {string} - El nombre del archivo temporal generado.
 */
generateTempFileName(prefix) {
    randomNumber := Random(100000, 999999)
    return prefix "-" randomNumber ".tmp"
}

/**
 * * Muestra un MsgBox siempre en la parte superior con un ícono según el tipo de mensaje.
 * @param {string} title - El título del MsgBox.
 * @param {string} message - El mensaje a mostrar en el MsgBox.
 * @param {string} type - El tipo de mensaje (Error, Warning, Info, Question).
 */
showTopMsgBox(title, message, type := "Info") {
    ; Determinar el ícono basado en el tipo de mensaje
    switch type {
        case "Error":
            icon := 0x10 ; Ícono de error
        case "Warning":
            icon := 0x30 ; Ícono de advertencia
        case "Info":
            icon := 0x40 ; Ícono de información
        case "Question":
            icon := 0x20 ; Ícono de pregunta
        default:
            icon := 0x40 ; Ícono de información por defecto
    }
    ; Mostrar el MsgBox con la opción Always On Top y el ícono seleccionado
    MsgBox(message, title, icon | 0x40000)
}


;todo---SECTION: Process Management

/**
 * * Inicializa el script verificando la existencia de archivos requeridos y creando la GUI.
 */
init() {
    global requiredFiles
    fileExtents := requiredFiles.extents

    if (!FileExist(fileExtents)) {
        message := "El archivo requerido '" fileExtents "' no existe. Por favor, asegúrese de que el archivo está presente en el directorio adecuado y contiene las extensiones válidas, una por línea, sin comentarios o espacios en blanco."
        showTopMsgBox("Archivo Requerido No Encontrado", message, "Error")
        ExitApp 1
    }

    ; Inicializar la GUI
    createGui()
}

/**
 * * Verifica si el proceso de generación está en curso y muestra un mensaje si es así.
 * @return {boolean} - Verdadero si el proceso está en curso, falso en caso contrario.
 */
checkIfGenerating() {
    global isGenerating
    if (isGenerating) {
        showTopMsgBox("Proceso de Generación en Curso", "El proceso de generación del árbol aún está en curso. Por favor, espere.", "Warning")
        return 1
    }
}

/**
 * * Procesa la carpeta seleccionada, generando el árbol de directorios y/o los contenidos de los archivos.
 * @param {string} folderPath - La ruta de la carpeta.
 */
processFolder(folderPath) {
    global isGenerating, myGui

    if (checkIfGenerating()) {
        return
    }

    isGenerating := true
    myGui["GenerateText"].Value := "Generating..."  ; Cambia el texto a "Generating..."

    ; Normalizar la ruta
    folderPath := normalizePath(folderPath)
    if (!folderPath) {
        endGeneration()
        return
    }

    ; Generar el árbol de directorios
    if (checkAndGenerateDirectoryTree(folderPath)) {
        endGeneration()
        return
    }

    ; Generar el contenido de los archivos
    if (checkAndGenerateFilesContents(folderPath)) {
        endGeneration()
        return
    }

    ; Combinar archivos y finalizar
    mergeFiles()
    endGeneration()
}

/**
 * * Finaliza el proceso de generación limpiando archivos temporales y estableciendo la bandera de generación.
 */
endGeneration() {
    global isGenerating, myGui
    clearTemp()
    isGenerating := false
    myGui["GenerateText"].Value := "Generate:"  ; Cambia el texto de vuelta a "Generate:"
}

/**
 * * Verifica si el checkbox de Directory Tree está activado y llama a generateDirectoryTree si es así.
 * @param {string} folderPath - La ruta de la carpeta.
 */
checkAndGenerateDirectoryTree(folderPath) {
    global directoryTreeCheckbox
    if (directoryTreeCheckbox.Value) {
        return generateDirectoryTree(folderPath)
    }
}

/**
 * * Verifica si el checkbox de Files Contents está activado y llama a generateFilesContents si es así.
 * @param {string} folderPath - La ruta de la carpeta.
 */
checkAndGenerateFilesContents(folderPath) {
    global fileContentsCheckbox
    if (fileContentsCheckbox.Value) {
        return generateFilesContents(folderPath)
    }
}


;todo---SECTION: Directory Tree Generation

/**
 * * Genera el árbol de archivos de la carpeta seleccionada.
 * @param {string} folderPath - La ruta de la carpeta.
 */
generateDirectoryTree(folderPath) {
    global tempFiles
    temp := tempFiles.dirTree
    ; Usar PowerShell para generar el árbol de archivos con caracteres Unicode correctamente
    command := "powershell -NoProfile -ExecutionPolicy Bypass -Command " "& {tree /f '" folderPath "' | Out-File -FilePath " temp " -Encoding utf8}"
    RunWait(command, , "Hide")
    if (A_LastError) {
        MsgBox("+AlwaysOnTop Error al generar el árbol de archivos. Por favor, intente nuevamente.")
        return 1
    }

    ; Leer el archivo de salida y eliminar las dos primeras líneas
    fileTree := FileRead(temp, "UTF-8")
    fileTreeArray := StrSplit(fileTree, "`n")
    ; Eliminar las dos primeras líneas
    fileTreeArray.RemoveAt(1)
    fileTreeArray.RemoveAt(1)

    ; Obtener el nombre de la carpeta principal
    folderName := getMainFolderName(folderPath)

    ; Reemplazar la primera línea con el nombre de la carpeta principal
    fileTreeArray[1] := folderName
    ; Filtrar líneas vacías y eliminar espacios en blanco y tabulaciones
    fileTreeNew := ""
    for line in fileTreeArray {
        if (StrLen(Trim(line)) > 0) {
            fileTreeNew .= line "`n"
        }
    }
    ; Reescribir el archivo con las modificaciones
    fileDel(temp)
    FileAppend(fileTreeNew, temp, "UTF-8")
}


;todo---SECTION: Files Contents Generation

/**
 * * Genera el contenido de los archivos de la carpeta seleccionada.
 * @param {string} folderPath - La ruta de la carpeta.
 */
generateFilesContents(folderPath) {
    global tempFiles, requiredFiles

    temp := tempFiles.filesContents
    fileExtents := requiredFiles.extents

    fileList := ""
    allowedExtensions := loadAllowedExtensions(fileExtents) ; Cargar extensiones permitidas desde archivo
    if (allowedExtensions.Length = 0) {
        showTopMsgBox("No se Encontraron Extensiones Permitidas", "No se encontraron extensiones permitidas. Asegúrese de que el archivo '" fileExtents "' existe y contiene las extensiones válidas, una por línea, sin comentarios o espacios en blanco.", "Error")
        return 1
    }

    mainFolder := getMainFolderName(folderPath)
    fileArray := []
    Loop Files, folderPath "\*.*", "R" {
        ; Obtener la ruta relativa al directorio principal
        relativePath := StrReplace(A_LoopFileFullPath, folderPath "\")
        ; Obtener la extensión del archivo
        fileExt := StrLower(StrSplit(A_LoopFileFullPath, ".").Pop())
        ; Verificar si la extensión está en la lista de archivos permitidos
        if hasValue(allowedExtensions, fileExt) {
            fileArray.Push(relativePath)
        }
    }

    if (fileArray.Length = 0) {
        fileList := "[Aviso No Hay Archivos que Coincidan con las Extensiones Permitidas]"
    } else {
        for index, relativePath in fileArray {
            try {
                fileContents := FileRead(folderPath "\" relativePath, "UTF-8")
                errorFileContents := false
            } catch {
                fileContents := ""
                errorFileContents := true
            }

            if (errorFileContents)
                fileList .= "#### Archivo '" relativePath "' [Error Lectura del archivo]"
            else
                fileList .= "#### Archivo '" relativePath "': `n" fileContents

            if (index < fileArray.Length) {
                fileList .= "`n`n"
            }
        }
    }

    ; Escribir los contenidos en un archivo de salida
    fileDel(temp)
    FileAppend(fileList, temp, "UTF-8")
}


;todo---SECTION: File Management

/**
 * * Elimina un archivo si existe.
 * @param {string} file - La ruta del archivo a eliminar.
 */
fileDel(file) {
    if FileExist(file)
        FileDelete(file)
}

/**
 * * Elimina archivos temporales utilizados durante el procesamiento.
 */
clearTemp() {
    global tempFiles
    fileDel(tempFiles.dirTree)
    fileDel(tempFiles.filesContents)
}

/**
 * * Une los archivos dirTree.tmp y filesContents.tmp en uno solo según los checkboxes activados.
 * Elimina los archivos intermedios y copia el contenido final al portapapeles.
 */
mergeFiles() {
    global directoryTreeCheckbox, fileContentsCheckbox, tempFiles

    temp1 := tempFiles.dirTree
    temp2 := tempFiles.filesContents
    output := tempFiles.output

    outputContent := ""
    spacer := "`n`n"

    ; Agregar el contenido del árbol de directorios si está seleccionado
    if (directoryTreeCheckbox.Value) {
        try {
            fileTree := FileRead(temp1, "UTF-8")
            outputContent .= "### Estructura de Archivos:`n" fileTree
            if (fileContentsCheckbox.Value) {
                outputContent .= spacer
            }
        } catch {
            showTopMsgBox("Error al Leer Archivo de Árbol de Directorios", "No se pudo leer dirTree.tmp.", "Error")
        }
    }

    ; Agregar el contenido de los archivos si está seleccionado
    if (fileContentsCheckbox.Value) {
        try {
            fileContents := FileRead(temp2, "UTF-8")
            outputContent .= "### Contenido de los Archivos:`n" fileContents
        } catch {
            showTopMsgBox("Error al Leer Archivo de Contenido de Archivos", "No se pudo leer filesContents.tmp.", "Error")
        }
    }

    ; Escribir el contenido combinado en output.tree
    try {
        fileDel(output)
        FileAppend(outputContent, output, "UTF-8")
    } catch {
        showTopMsgBox("Error al Escribir Archivo de Salida", "No se pudo escribir en output.tree.", "Error")
        return
    }

    ; Copiar el contenido final al portapapeles
    A_Clipboard := ""
    ClipWait(1, 0)
    A_Clipboard := outputContent
    if !ClipWait(2) {
        showTopMsgBox("Error al Copiar al Portapapeles", "El intento de copiar texto al portapapeles falló.", "Error")
        return
    }

    showTopMsgBox("Información Copiada", "Información copiada al portapapeles.", "Info")
}


;* Inicializa el programa.
init()