#Requires AutoHotkey v2.0.18
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


;todo---MARK: GLOBAL VARIABLES

/**
 * ? Objeto principal que contiene la configuración y metadatos del programa.
 * @global {Object}
 * @property {string} name - Nombre del programa.
 * @property {string} version - Versión del programa. Actualizar con cada cambio.
 * @property {string} description - Descripción del programa.
 * @property {string} fullDescription - Combinación del nombre, versión y descripción del programa.
 */
global PROGRAM := {
    name: "FileTreeGen",
    version: "v1.5",
    description: "File Tree Generation",
    fullDescription: ""
}

; Inicializar fullDescription
PROGRAM.fullDescription := PROGRAM.name " " PROGRAM.version " - " PROGRAM.description

/**
 * ! Archivos de configuración del programa.
 * @global {Object}
 */
global confiFileTreeGen := "FileTreeGen.conf" ; Archivo de configuracion que contiene las extensiones permitidas y los archivos ignorados en el proceso "Files Contents"

/**
 * ! Archivos temporales utilizados durante la ejecución del programa.
 * @global {Object}
 */
global tempFiles := {
    dirTree: generateTempFileName("tree_output"), ; Archivo temporal para el árbol de directorios
    filesContents: generateTempFileName("filesContents_output"), ; Archivo temporal para los contenidos de archivos
    output: "output.md" ; Archivo de salida combinado
}

/**
 * ; Bandera para evitar ejecuciones concurrentes.
 * @global {boolean}
 */
global isGenerating := false


;todo---MARK: Environment configuration

A_MaxHotkeysPerInterval := 1000
KeyHistory 0
ListLines 0
SetWinDelay 0
SetKeyDelay -1, -1


;todo---MARK: Development Hotkeys

;! Uso solo para modo desarollo
#HotIf !A_IsCompiled
^s:: {
    Send("^s")  ; Simula Ctrl+S para guardar el archivo
    clearTemp() ; Elimina todos los posibles archivos residuales.
    Sleep(100)  ; Pequeño retraso para asegurar que el archivo se guarde
    Reload()  ; Recarga el script
}
#HotIf


;todo---MARK: GUI Management

/**
 * * Crear una GUI para generar un árbol de archivos de un directorio arrastrado.
 */
createGui() {
    global PROGRAM, myGui, folderEdit, folderButton, directoryTreeCheckbox, fileContentsCheckbox, generateText
    myGui := Gui("+AlwaysOnTop", PROGRAM.fullDescription)
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
    directoryTreeCheckbox.OnEvent("Click", (*) => ensureOneCheckboxChecked(directoryTreeCheckbox))
    fileContentsCheckbox.OnEvent("Click", (*) => ensureOneCheckboxChecked(fileContentsCheckbox))

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
    clearTemp()
    ExitApp
}

/**
 * * Asegura que al menos uno de los checkboxes esté activado.
 */
ensureOneCheckboxChecked(checkbox) {
    global directoryTreeCheckbox, fileContentsCheckbox
    if (!directoryTreeCheckbox.Value && !fileContentsCheckbox.Value) {
        checkbox.Value := true
    }
}

/**
 * * Selecciona una carpeta mediante un diálogo y lo mantiene en la parte superior.
 */
selectFolder(*) {
    if (checkIfGenerating())
        return

    ; Configurar el temporizador para asegurarse de que el diálogo se mantenga siempre en la parte superior
    ; SetTimer MakeTopmost, 50
    SetTimer MakeTopmost, -100

    ; Crear el diálogo de selección de carpeta
    folderPath := FileSelect("D", "", "Seleccione una carpeta")

    ; Desactivar el temporizador después de cerrar el diálogo
    SetTimer MakeTopmost, 0

    processFolder(folderPath)
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
 * @param {Object} thisGui - La GUI donde se soltaron los archivos.
 * @param {Object} ctrl - El control donde se soltaron los archivos.
 * @param {array} fileArray - Lista de archivos arrastrados.
 */
guiDropFiles(thisGui, ctrl, fileArray, *) {
    if (checkIfGenerating())
        return
    processFolder(fileArray[1])
}

/**
 * * Maneja el evento de tecla presionada.
 * @param {WPARAM} wParam - El código de la tecla presionada.
 * @param {LPARAM} lParam - Información adicional sobre la tecla presionada.
 * @param {MSG} msg - El mensaje de la tecla presionada.
 * @param {HWND} hwnd - El identificador de la ventana.
 */
WM_KeyDown(wParam, lParam, msg, hwnd) {
    global PROGRAM, folderEdit
    if (checkIfGenerating())
        return
    if (wParam = 0x0D) { ; Código de la tecla Enter
        if (WinActive(PROGRAM.fullDescription)) {
            processFolder(folderEdit.Value)
        }
    }
}


;todo---MARK: Utility Functions


;
;
;


;;MARK:*
;^----------------Array----------------^;

/**
 * * Verifica si un array contiene un valor específico.
 * @param {Array} array - El array en el que buscar.
 * @param {string} value - El valor a buscar.
 * @return {boolean} - Verdadero si el valor está en la lista, falso en caso contrario.
 */
arrayHasValue(array, value) {
    for item in array {
        if (item = value)
            return true
    }
    return false
}

/**
 * * Elimina los elementos duplicados de un array.
 * @param {Array} arr - El array del que se eliminarán los duplicados.
 * @return {Array} - Un nuevo array sin elementos duplicados.
 */
removeDuplicates(arr) {
    uniqueArray := Array()
    for item in arr {
        if !arrayHasValue(uniqueArray, item) {
            uniqueArray.Push(item)
        }
    }
    return uniqueArray
}

/**
 * * Combina múltiples arrays en uno solo.
 * @param {Array} arrays - Uno o más arrays a combinar.
 * @return {Array} - Un nuevo array que contiene todos los elementos de los arrays proporcionados.
 */
combineArrays(arrays*) {
    combinedArray := []
    for each, arr in arrays {
        for each, item in arr {
            combinedArray.Push(item)
        }
    }
    return combinedArray
}

;;MARK:*
;^----------------Files----------------^;

/**
 * * Elimina un archivo si existe.
 * @param {string} file - La ruta del archivo a eliminar.
 */
fileDel(file) {
    if FileExist(file)
        FileDelete(file)
}

/**
 * * Obtiene el nombre de la carpeta actual de una ruta.
 * @param {string} folderPath - La ruta de la carpeta.
 * @return {string} - El nombre de la carpeta principal.
 */
getCurrentFolderName(folderPath) {
    ; Utilizar SplitPath para obtener el nombre de la carpeta actual
    SplitPath(RTrim(folderPath, "\"), , &OutDir, , &OutDirName)

    ; Devolver el nombre de la carpeta actual
    return OutDirName
}

/**
 * * Normaliza una ruta y verifica su existencia. Opcionalmente, establece un directorio de trabajo principal.
 * @param {String} path - La ruta a normalizar.
 * @param {String} [mainPath] - (Opcional) El directorio de trabajo principal para resolver la ruta.
 * @returns {String|Boolean} - Devuelve la ruta normalizada si existe, de lo contrario, devuelve false.
 */
normalizePath(path, mainPath?) {
    ;; Guardar el directorio de trabajo actual si se proporciona mainPath
    if (IsSet(mainPath)) {
        originalDir := A_WorkingDir
        SetWorkingDir(mainPath)
    }
    ;; Primera llamada para obtener el tamaño necesario del buffer
    cc := DllCall("GetFullPathName", "str", path, "uint", 0, "ptr", 0, "ptr", 0, "uint")
    buf := Buffer(cc * 2) ;; Crear buffer con el tamaño adecuado
    ;; Segunda llamada para obtener la ruta completa
    result := DllCall("GetFullPathName", "str", path, "uint", cc, "ptr", buf, "ptr", 0)
    cleanPath := StrGet(buf) ;; Convertir el buffer a cadena

    ;; Restaurar el directorio de trabajo original si se proporcionó mainPath
    if (IsSet(mainPath))
        SetWorkingDir(originalDir)
    ;; Eliminar barra invertida final si existe
    if (SubStr(cleanPath, -1, 1) = "\")
        cleanPath := SubStr(cleanPath, 1, -1)
    ;; Verificar si la ruta existe
    if !FileExist(cleanPath)
        return false
    return cleanPath
}

/**
 * * Obtiene la extensión de un archivo a partir de su ruta.
 * @param {string} filePath - La ruta del archivo.
 * @returns {string} La extensión del archivo, sin incluir el punto. Si no tiene extensión, retorna una cadena vacía.
 */
getFileExtension(filePath) {
    ; Definir una variable para almacenar la extensión del archivo
    OutExtension := ""

    ; Utilizar SplitPath para obtener la extensión del archivo
    SplitPath(filePath, , , &OutExtension)

    ; Devolver la extensión (si existe) o una cadena vacía
    return StrLower(OutExtension)
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

;;MARK:*
;^----------------Other----------------^;

/**
 * * Muestra un MsgBox siempre en la parte superior con un ícono según el tipo de mensaje.
 * @param {string} message - El mensaje a mostrar en el MsgBox.
 * @param {string} title - El título del MsgBox.
 * @param {string} type - El tipo de mensaje (Error, Warning, Info, Question, Default).
 * @param {boolean} async - Si es verdadero, muestra el MsgBox asincrónicamente.
 */
showTopMsgBox(message := "", title := "", type := "Default", async := false) {
    ; Convertir el tipo de mensaje a minúsculas para que el switch no distinga entre mayúsculas y minúsculas
    type := StrLower(type)

    ; Determinar el ícono basado en el tipo de mensaje
    switch type {
        case "error":
            icon := 0x10 ; Ícono de error
        case "warning":
            icon := 0x30 ; Ícono de advertencia
        case "info":
            icon := 0x40 ; Ícono de información
        case "question":
            icon := 0x20 ; Ícono de pregunta
        default:
            ; Capturar el número de línea utilizando una excepción
            try {
                ; Forzar una excepción para capturar el contexto de la llamada
                throw ValueError("Capturing line number", -1)
            } catch ValueError as err {
                callerLine := err.Line
            }
            icon := 0 ; Sin ícono por defecto

            ; Formatear el mensaje según las combinaciones de message y title
            if (message = "" and title = "") {
                message := ""
            } else if (message != "" and title != "") {
                message := message ':`n"' title '"'
            } else if (message = "" and title != "") {
                message := '"' title '"'
            } else if (title != "" and message = "") {
                message := title
            }

            title := "Line: " callerLine
    }

    ; Si es asincrónico, usar SetTimer para mostrar el MsgBox
    if async {
        SetTimer((() => MsgBox(message, title, icon | 0x40000)), -1)
    } else {
        ; Mostrar el MsgBox con la opción Always On Top y el ícono seleccionado
        MsgBox(message, title, icon | 0x40000)
    }
}


;todo---MARK: Functions


;
;
;


;;MARK:*
;^----------------Files----------------^;

/**
 * * Valida si una ruta es una carpeta válida.
 * @param {string} path - La ruta a validar.
 * @return {string|false} - La ruta validada si es válida, de lo contrario, false.
 */
isValidFolder(path) {
    if (!FileExist(path) or FileExist(path) != "D" and FileExist(path) != "AD" and FileExist(path) != "RD") {
        return false
    }
    return true
}

/**
 * * Analiza el archivo de configuración y devuelve los elementos del array especificado.
 * @param {string} pathConfigFile - La ruta del archivo de configuración.
 * @param {string} section - La sección del archivo de configuración a analizar.
 * @param {string} arrayName - El nombre del array a extraer.
 * @return {Array} - Una lista de elementos del array especificado.
 */
analyzeConfigFile(pathConfigFile, section, arrayName) {
    if !FileExist(pathConfigFile) {
        showTopMsgBox("El archivo de configuración no existe. Asegúrese de que '" pathConfigFile "' está en el directorio correcto y contiene las entradas válidas.", "Archivo de Configuración No Encontrado", "Error", true)
        return []
    }

    data := Array()
    currentSection := ""  ;; Inicializa la sección actual
    inTargetSection := false  ;; Bandera para indicar si estamos en la sección objetivo
    inArray := false  ;; Bandera para indicar si estamos dentro del array

    Loop Read, pathConfigFile {
        line := Trim(A_LoopReadLine)
        ;; Ignora líneas vacías o comentarios
        if (line != "" && SubStr(line, 1, 1) != "#") {
            ;; Detecta el inicio de una nueva sección
            if (Trim(SubStr(line, 1, 1) = "[" && SubStr(line, -1, 1) = "]")) {
                currentSection := SubStr(line, 2, -1)  ;; Extrae el nombre de la sección
                inTargetSection := (currentSection = section)  ;; Comprueba si es la sección objetivo
                continue
            }

            ;; Si estamos en la sección objetivo
            if inTargetSection {
                ;; Detecta el inicio del array
                if (InStr(line, arrayName) && InStr(line, "=")) {
                    inArray := !parseArrayContent(line, data) ;; La salida evalua si el array aun esta sin terminar
                    continue
                }

                if (inArray) {
                    inArray := !parseArrayContent(line, data)
                }
            }
        }
    }

    return removeDuplicates(data)  ; Elimina elementos duplicados de la lista y la devuelve
}

parseArrayContent(lineContent, data) {
    isEnd := false

    if InStr(lineContent, "[")
        lineContent := SubStr(lineContent, InStr(lineContent, "[") + 1)  ;; Extrae el contenido del array después de '['

    ;; Procesa cada elemento del array en la misma línea
    ;; Dividir el contenido en elementos separados por comas
    for index, item in StrSplit(lineContent, ",") {
        ; showTopMsgBox("lineContent[" index "]", item)

        ;; Si se encuentra un ']' sin comillas, finalizar la lectura del array
        if (SubStr(item, -1, 1) = "]") {

            item := Trim(StrReplace(StrReplace(SubStr(item, 1, StrLen(item) - 1), '"'), "'"))
            ; showTopMsgBox("lineContent[" index "]", item)

            isEnd := true
        }

        if (!isEnd) {
            ;; Si no queremos que contengan espacios usamos `trim`
            item := Trim(StrReplace(StrReplace(item, '"'), "'"))  ;; Elimina comillas y espacios
            ; item := StrReplace(StrReplace(item, '"'), "'")  ;; Elimina comillas
            ; showTopMsgBox("lineContent[" index "]", item)
        }

        if (item != "") {
            ; showTopMsgBox("lineContent[" index "]", item)
            data.Push(item)  ;; Agrega el elemento a la lista de datos
            if (isEnd)
                return isEnd
        }
    }
    return isEnd
}


;todo---MARK: Process Management


;
;
;


;;MARK:*
;^----------------Checks----------------^;

/**
 * * Verifica si el proceso de generación está en curso y muestra un mensaje si es así.
 * @return {boolean} - Verdadero si el proceso está en curso, falso en caso contrario.
 */
checkIfGenerating() {
    global isGenerating
    if (isGenerating) {
        showTopMsgBox("El proceso de generación del árbol aún está en curso. Por favor, espere.", "Proceso de Generación en Curso", "Warning", true)
        return true
    }
}

/**
 * * Verifica si el checkbox de Directory Tree está activado y llama a generateDirectoryTree si es así.
 */
checkAndGenerateDirectoryTree() {
    global directoryTreeCheckbox
    if (directoryTreeCheckbox.Value) {
        return generateDirectoryTree()
    }
}

/**
 * * Verifica si el checkbox de Files Contents está activado y llama a generateFilesContents si es así.
 */
checkAndGenerateFilesContents() {
    global fileContentsCheckbox
    if (fileContentsCheckbox.Value) {
        return generateFilesContents()
    }
}

;;MARK:*
;^----------------Process----------------^;

/**
 * * Inicializa el script verificando la existencia de archivos requeridos y creando la GUI.
 */
init() {
    global confiFileTreeGen
    fileConfi := confiFileTreeGen

    if (!FileExist(fileConfi)) {
        message := "El archivo requerido '" fileConfi "' no existe. Por favor, asegúrese de que el archivo está presente en el directorio adecuado y contiene datos válidos, uno por línea, sin comentarios o espacios en blanco."
        showTopMsgBox(message, "Archivo Requerido No Encontrado", "Error")
        ExitApp(1)
    }

    ; Inicializar la GUI
    createGui()
}

/**
 * * Procesa la carpeta seleccionada, generando el árbol de directorios y/o los contenidos de los archivos.
 * @param {string} folderPath - La ruta de la carpeta.
 */
processFolder(folderPath) {
    global mainFolderPath, isGenerating, myGui, folderEdit

    if (folderPath = "")
        return

    if (checkIfGenerating()) {
        return
    }

    ; Normalizar la ruta
    folderPath := normalizePath(folderPath)

    if (!folderPath = false) {
        folderEdit.Value := folderPath
    }

    if (!isValidFolder(folderPath)) {
        showTopMsgBox("Por favor, ingrese una ruta de carpeta válida.", "Ruta de Carpeta Inválida", "Error", true)
        endGeneration()
        return
    }

    isGenerating := true
    myGui["GenerateText"].Value := "Generating..."  ; Cambia el texto a "Generating..."

    mainFolderPath := folderPath

    ; Generar el árbol de directorios
    if (checkAndGenerateDirectoryTree()) {
        endGeneration()
        return
    }

    ; Generar el contenido de los archivos
    if (checkAndGenerateFilesContents()) {
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


;todo---MARK: Files Generation


;
;
;


;;MARK:*
;^----------------Use analyzeConfigFile----------------

getAnalyzeConfigFile(section, arrayName) {
    return removeDuplicates(
        combineArrays(
            analyzeConfigFile(confiFileTreeGen, "AllDefault", arrayName),
            analyzeConfigFile(confiFileTreeGen, section, arrayName)
        )
    )
}

getAllowedExtensions(section, arrayName) {
    global confiFileTreeGen

    allowedExtensions := getAnalyzeConfigFile(section, arrayName)
    if (allowedExtensions.Length = 0) {
        showTopMsgBox("No se encontraron extensiones permitidas. Asegúrese de que el archivo '" confiFileTreeGen "' existe y contiene las extensiones válidas, una por línea, sin comentarios o espacios en blanco.", "No se Encontraron Extensiones Permitidas", "Error", true)
        return 1
    }
    return allowedExtensions
}


getIgnoredFiles(section, arrayName) {
    ignoredFiles := getAnalyzeConfigFile(section, arrayName)

    newIgnoredFiles := Array()
    ;; Aplicar el filtro cleanPath a cada elemento de ignoredFiles
    for index, item in ignoredFiles {
        cleanItem := normalizePath(item, mainFolderPath)
        ; showTopMsgBox('normalizePath(  "' item '"  )', cleanItem)

        if (cleanItem) {
            newIgnoredFiles.Push(cleanItem)
        }
    }

    ignoredFiles := newIgnoredFiles

    ;; Se vuelven a eliminar los duplicados porque ahora se comprarn con la ruta absoluta para evitar rutas relativas repetidas.
    ignoredFiles := removeDuplicates(ignoredFiles)

    ; for index, item in ignoredFiles {
    ;     showTopMsgBox("ignoredFiles[" index "]", item)
    ; }

    return ignoredFiles
}


;;MARK:*
;^----------------Directory Tree Generation----------------

/**
 * * Genera el árbol de archivos de la carpeta seleccionada.
 * 
 * Posible error: Si ocurre un error al ejecutar el comando de PowerShell, puede ser debido a:
 * 1. PowerShell no está instalado o habilitado en el sistema.
 * 2. Restricciones de políticas de ejecución de scripts en PowerShell.
 * 
 * Solución: 
 * 1. Verifique que PowerShell está instalado y habilitado en su sistema.
 * 2. Revise las políticas de ejecución de PowerShell y ajuste según sea necesario.
 */
generateDirectoryTree() {
    global mainFolderPath, tempFiles
    temp := tempFiles.dirTree


    ;!(DESAROLLO) Obtenemos la informacion de los archivos requerida
    allowedExtensions := getAllowedExtensions("FilesContents", "allowed_extensions")
    if (allowedExtensions = 1)
        return 1 ;; Error no hay extensiones permitidas
    ignoredFiles := getIgnoredFiles("FilesContents", "ignored_files")


    ;; Usar PowerShell para generar el árbol de archivos con caracteres Unicode correctamente
    command := "powershell -NoProfile -ExecutionPolicy Bypass -Command " "& {tree /f '" mainFolderPath "' | Out-File -FilePath " temp " -Encoding utf8}"
    RunWait(command, , "Hide")
    if (A_LastError) {
        showTopMsgBox("Posibles causas: `n1. PowerShell no está instalado o habilitado en el sistema.`n2. Restricciones de políticas de ejecución de scripts en PowerShell.`n`nSolución: `n1. Verifique que PowerShell está instalado y habilitado en su sistema.`n2. Revise las políticas de ejecución de PowerShell y ajuste según sea necesario.", "Error al generar el árbol de archivos", "Error", true)
        return 1
    }

    ;; Leer el archivo de salida y eliminar las dos primeras líneas
    fileTree := FileRead(temp, "UTF-8")
    fileTreeArray := StrSplit(fileTree, "`n")
    ;; Eliminar las dos primeras líneas
    fileTreeArray.RemoveAt(1)
    fileTreeArray.RemoveAt(1)

    ;; Obtener el nombre de la carpeta principal
    folderName := getCurrentFolderName(mainFolderPath)

    ;; Reemplazar la primera línea con el nombre de la carpeta principal
    fileTreeArray[1] := folderName
    ;; Filtrar líneas vacías, eliminar espacios en blanco y tabulaciones, y omitir líneas que contengan el valor de temp
    fileTreeNew := "``````tree`n"
    for line in fileTreeArray {
        if (StrLen(Trim(line)) > 0 && !InStr(line, temp)) {
            fileTreeNew .= line "`n"
        }
    }
    fileTreeNew .= "```````n"

    ;; Reescribir el archivo con las modificaciones
    fileDel(temp)
    FileAppend(fileTreeNew, temp, "UTF-8")
}


;;MARK:*
;^----------------Files Contents Generation----------------

/**
 * * Genera el contenido de los archivos de la carpeta seleccionada.
 */
generateFilesContents() {
    global mainFolderPath, tempFiles

    temp := tempFiles.filesContents

    ;; Obtenemos la informacion de los archivos requerida
    allowedExtensions := getAllowedExtensions("FilesContents", "allowed_extensions")
    if (allowedExtensions = 1)
        return 1 ;; Error no hay extensiones permitidas
    ignoredFiles := getIgnoredFiles("FilesContents", "ignored_files")


    fileArray := []

    ;; Crear una lista de carpetas a ignorar
    ignoreDirs := []
    for each, item in ignoredFiles {
        if (DirExist(item))  ;; Si es un directorio
            ignoreDirs.Push(item)
    }

    Loop Files, mainFolderPath "\*.*", "R" {
        ;; Obtener la ruta relativa al directorio principal
        relativePath := StrReplace(A_LoopFileFullPath, mainFolderPath "\")
        ;; Obtener la extensión del archivo
        fileExt := getFileExtension(A_LoopFileFullPath)

        ;; Verificar si el archivo o su carpeta está en la lista de ignorados
        ignoreFile := false
        for dir in ignoreDirs {
            if (InStr(A_LoopFileFullPath, dir "\") = 1) {
                ignoreFile := true
                break
            }
        }

        ;; Verificar si la extensión está en la lista de archivos permitidos y no está en la lista de archivos completos ignorados
        if !ignoreFile && arrayHasValue(allowedExtensions, fileExt) && !arrayHasValue(ignoredFiles, A_LoopFileFullPath) {
            ; showTopMsgBox(relativePath, A_LoopFileFullPath)
            fileArray.Push(relativePath)
        }
    }


    if (fileArray.Length = 0) {
        fileList := "**[Aviso: No Hay Archivos que Coincidan con la Configuracion Actual]**"
    } else {
        for index, relativePath in fileArray {
            fileExtension := getFileExtension(relativePath)

            try {
                fileContents := FileRead(mainFolderPath "\" relativePath, "UTF-8")
                errorFileContents := false
            } catch {
                fileContents := ""
                errorFileContents := true
            }

            if (errorFileContents)
                fileList .= "#### Archivo ``" relativePath "`` **[Error: Lectura del archivo]**"
            else
                fileList .= "#### Archivo ``" relativePath "``: `n````````" fileExtension " `n" fileContents "`n````````"

            if (index < fileArray.Length) {
                fileList .= "`n`n"
            }
        }
    }

    ;; Escribir los contenidos en un archivo de salida
    fileDel(temp)
    FileAppend(fileList, temp, "UTF-8")
}


;todo---MARK: File Management

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

    outputContent := "## Índice (File Tree Generation)`n"
    output := tempFiles.output
    spacer := "`n`n"

    if (directoryTreeCheckbox.Value)
        outputContent .= "- [Árbol de directorios](#Directory-Tree)`n"
    if (!fileContentsCheckbox.Value)
        outputContent .= "`n"
    if (fileContentsCheckbox.Value)
        outputContent .= "- [Contenido de los archivos](#Files-Contents)`n`n"

    ;; Agregar el contenido del árbol de directorios si está seleccionado
    if (directoryTreeCheckbox.Value) {
        try {
            fileTree := FileRead(tempFiles.dirTree, "UTF-8")
            outputContent .= "### Directory Tree:`n" fileTree spacer
        } catch {
            showTopMsgBox("No se pudo leer dirTree.tmp.", "Error al Leer Archivo de Árbol de Directorios", "Error", true)
        }
    }

    ;; Agregar el contenido de los archivos si está seleccionado
    if (fileContentsCheckbox.Value) {
        try {
            fileContents := FileRead(tempFiles.filesContents, "UTF-8")
            outputContent .= "### Files Contents:`n" fileContents
        } catch {
            showTopMsgBox("No se pudo leer filesContents.tmp.", "Error al Leer Archivo de Contenido de Archivos", "Error", true)
        }
    }

    ;; Escribir el contenido combinado en `output`
    try {
        FileDelete(output)
        FileAppend(outputContent, output, "UTF-8")
    } catch {
        showTopMsgBox("No se pudo escribir en `"" output "`".", "Error al Escribir Archivo de Salida", "Error", true)
        return
    }

    ; ;; Copiar el contenido final al portapapeles
    ; A_Clipboard := outputContent
    ; if !ClipWait(2) {
    ;     showTopMsgBox("El intento de copiar texto al portapapeles falló.", "Error al Copiar al Portapapeles", "Error", true)
    ;     return
    ; }

    ; showTopMsgBox("Información copiada al portapapeles.", "Información Copiada", "Info", true)
}


;todo---MARK: Initialization


;
;
;


;;MARK:*
;^----------------Init----------------^;

;* Inicializa el programa.
init()