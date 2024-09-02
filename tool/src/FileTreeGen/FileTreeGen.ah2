#Requires AutoHotkey v2.0.18
#SingleInstance Force
/*@Ahk2Exe-Keep
#NoTrayIcon
*/

#Include "../../Libs/AutoHotKey/v2-Codevaried/Lib/Extensions/Array.ahk"
#Include "../../Libs/AutoHotKey/v2-Codevaried/Lib/Extensions/String.ahk"
; #Include "../../Libs/AutoHotKey/v2-Codevaried/Lib/Misc/Misc.ahk"


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
 * @autor (CodeVaried) => Eloy Navarro Escarabajal
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
    version: "v2.4",
    description: "File Tree Generation",
    fullDescription: ""
}

; Inicializar fullDescription
PROGRAM.fullDescription := PROGRAM.name " " PROGRAM.version " - " PROGRAM.description

/**
 * ? Archivos de configuración del programa.
 * @global {Object}
 * @property {string} confiFileTreeGen - Archivo de configuración que contiene las extensiones permitidas y los archivos ignorados.
 */
global confiFileTreeGen := "FileTreeGen.conf"


;;MARK:*
;^----------------Temporary Directories----------------^;

/**
 * ? Nombre del directorio principal temporal.
 * @global {string}
 */
global tempMainDir := A_Temp "\" generateTempName("FileTreeGen")

/**
 * ? Archivos temporales utilizados durante la ejecución del programa.
 * @global {Object}
 * @property {string} dir_filesTree - Directorio temporal para almacenar el árbol de archivos.
 * @property {string} file_dirTree - Archivo temporal para el árbol de directorios.
 * @property {string} file_filesContents - Archivo temporal para los contenidos de archivos.
 * @property {string} output - Archivo de salida combinado.
 */
global tempFiles := {
    dir_filesTree: tempMainDir "\FilesTree",
    file_dirTree: tempMainDir "\tree_output.tmp",                ;; Archivo temporal para el árbol de directorios
    file_filesContents: tempMainDir "\filesContents_output.tmp", ;; Archivo temporal para los contenidos de archivos
    output: "output.md"                                          ;; Archivo de salida combinado
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
    Send("^s")  ;; Simula Ctrl+S para guardar el archivo
    clearTemp() ;; Elimina todos los posibles archivos residuales.
    Sleep(100)  ;; Pequeño retraso para asegurar que el archivo se guarde
    Reload()    ;; Recarga el script
}

^Esc:: {
    clearTemp()
    ExitApp(1)
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

    ;; Añadir controles a la GUI
    myGui.Add("Text", , "Arrastre una carpeta o selecciónela manualmente:")
    folderEdit := myGui.Add("Edit", "w400 vFolderPath")
    folderButton := myGui.Add("Button", "xp+263 y+5", "Seleccionar Carpeta")

    ;; Añadir texto "Generate:" con tamaño más grande y ajustar su posición y ancho
    generateText := myGui.Add("Text", "xm yp+10 w100 h23 vGenerateText", "Generate:").SetFont("s12", "Segoe UI")

    ;; Añadir CheckBoxes en línea y activarlos por defecto
    directoryTreeCheckbox := myGui.Add("CheckBox", "xm y+5 Checked", "Directory Tree")
    fileContentsCheckbox := myGui.Add("CheckBox", "x+10 Checked", "Files Contents")

    ;; Configurar eventos de botones y checkboxes
    folderButton.OnEvent("Click", selectFolder)
    directoryTreeCheckbox.OnEvent("Click", (*) => ensureOneCheckboxChecked(directoryTreeCheckbox))
    fileContentsCheckbox.OnEvent("Click", (*) => ensureOneCheckboxChecked(fileContentsCheckbox))

    ;; Configurar evento de arrastre
    myGui.OnEvent("DropFiles", guiDropFiles)

    ;; Configurar la captura de la tecla Enter
    OnMessage(0x0100, WM_KeyDown)

    ;; Configurar el evento de cierre de la GUI para finalizar el programa
    myGui.OnEvent("Close", closeProgram)

    ;; Mostrar la GUI centrada
    myGui.Show("AutoSize Center")
}

/**
 * * Maneja el cierre del programa.
 */
closeProgram(*) {
    clearTemp()
    ExitApp(0)
}

/**
 * * Asegura que al menos uno de los checkboxes esté activado.
 */
ensureOneCheckboxChecked(checkbox) {
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
    ;; Configurar el temporizador para asegurarse de que el diálogo se mantenga siempre en la parte superior
    ; SetTimer MakeTopmost, 50
    SetTimer MakeTopmost, -100

    ;; Crear el diálogo de selección de carpeta
    folderPath := FileSelect("D", "", "Seleccione una carpeta")

    ;; Desactivar el temporizador después de cerrar el diálogo
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
    if (checkIfGenerating())
        return
    if (wParam == 0x0D) { ; Código de la tecla Enter
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
 * * Elimina un directorio si existe.
 * @param {string} dir - La ruta de la carpeta a eliminar.
 */
dirDel(dir) {
    if DirExist(dir)
        DirDelete(dir, true)
}

/**
 * * Obtiene el nombre de la carpeta actual de una ruta.
 * @param {string} folderPath - La ruta de la carpeta.
 * @return {string} - El nombre de la carpeta principal.
 */
getCurrentFolderName(folderPath) => folderPath.RTrim("\").SplitPath().NameNoExt

/**
 * Normaliza una ruta y verifica su existencia. Opcionalmente, establece un directorio de trabajo principal.
 * @param {String} path - La ruta a normalizar.
 * @param {String} [mainPath] - (Opcional) El directorio de trabajo principal para resolver la ruta.
 * @returns {Object} - Devuelve un objeto con la ruta normalizada y un indicador de existencia.
 * @property {String} path - La ruta normalizada.
 * @property {Boolean} exist - Indica si la ruta existe.
 */
normalizePath(path, mainPath?) {
    ;; Guardar el directorio de trabajo actual si se proporciona mainPath
    if IsSet(mainPath) {
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
    if IsSet(mainPath)
        SetWorkingDir(originalDir)
    ;; Eliminar barra invertida final si existe
    cleanPath := cleanPath.Trim("\")
    ;; Verificar si la ruta existe
    if !FileExist(cleanPath)
        return { path: cleanPath, exist: false }
    return { path: cleanPath, exist: true }
}

/**
 * * Obtiene la extensión de un archivo a partir de su ruta.
 * @param {string} filePath - La ruta del archivo.
 * @returns {string} La extensión del archivo, sin incluir el punto. Si no tiene extensión, retorna una cadena vacía.
 */
getFileExtension(filePath) => filePath.SplitPath().Ext.ToLower()

/**
 * * Genera un nombre temporal utilizando un prefijo y el identificador único de la instancia del programa mas su extension `.tmp`.
 * @param {string} prefix - El prefijo para el nombre del archivo.
 * @return {string} - El nombre del archivo temporal generado.
 */
generateTempFileName(prefix) => prefix "-" A_ScriptHwnd ".tmp"

/**
 * * Genera un nombre temporal utilizando un prefijo y el identificador único de la instancia del programa.
 * @param {string} prefix - El prefijo para el nombre temporal.
 * @returns {string} - El nombre temporal generado.
 */
generateTempName(prefix) => prefix "-" A_ScriptHwnd

/**
 * * Obtiene el tamaño total de un directorio y opcionalmente verifica si no supera un tamaño máximo especificado.
 * @param {String} dirPath - La ruta del directorio.
 * @param {Int64} [maxSize] - (Opcional) El tamaño máximo permitido en bytes.
 * @param {Array} [ignoreFiles] - (Opcional) Array de archivos y directorios a ignorar.
 * @param {Array} [allowedExtensions] - (Opcional) Array de extensiones permitidas.
 * @returns {Int64|Int} - Devuelve el tamaño total del directorio si no se proporciona maxSize o si no supera el maxSize, de lo contrario, devuelve -1.
 */
getDirectorySize(dirPath, maxSize?, ignoreFiles := [], allowedExtensions := []) {
    totalSize := 0

    ;; Filtrar los directorios de la lista de ignorados
    ignoreDirs := ignoreFiles
    ignoreDirs.Filter(DirExist)

    ; Print(ignoreDirs, , MsgBox)

    ;; Iterar sobre todos los archivos y subdirectorios
    Loop Files, dirPath "\*", "FR" {
        ;; Obtener la ruta completa del archivo actual
        filePath := A_LoopFileFullPath
        fileExtension := A_LoopFileExt

        ;; Verificar si el archivo actual está en la lista de archivos a ignorar
        if (ignoreFiles.Length > 0 && ignoreFiles.HasValue(filePath)) {
            continue
        }

        ingnore := false
        ;; Verificar si el archivo actual está dentro de algún directorio a ignorar
        for dir in ignoreDirs {
            if dir !== "" {
                if (filePath.Find(dir "\")) {
                    ; Print("filePath: '" filePath "'", "-")
                    ; Print("filePath: '" filePath.SplitPath().FileName "'", "-")
                    ; Print("'" dir "'", "#")
                    ; Print(filePath.Find(dir "\"), "#")
                    ingnore := true
                    break
                }
            }
        }
        if ingnore
            continue

        ;; Verificar si la extensión del archivo está permitida, si se proporciona allowedExtensions
        if (allowedExtensions.Length > 0 && !allowedExtensions.HasValue(fileExtension)) {
            continue
        }

        ; Print("filePath: '" filePath "'", "Success")
        ; Print("filePath: '" filePath.SplitPath().FileName "'", "Success")

        ; Print(totalSize " + " A_LoopFileSize " = " totalSize + A_LoopFileSize, "")
        totalSize += A_LoopFileSize

        ;; Verificar si el tamaño supera el máximo permitido, si se proporciona maxSize
        if (IsSet(maxSize) && totalSize > maxSize) {
            ; Print("(" totalSize - maxSize "b) De Más", "# Fail")
            return -1
        }
    }
    ; Print("(" totalSize "b) en Total", "# Success")
    return totalSize
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
    ;; Convertir el tipo de mensaje a minúsculas para que el switch no distinga entre mayúsculas y minúsculas
    type := StrLower(type)

    ;; Determinar el ícono basado en el tipo de mensaje
    switch type {
        case "error":
            icon := 0x10 ;; Ícono de error
        case "warning":
            icon := 0x30 ;; Ícono de advertencia
        case "info":
            icon := 0x40 ;; Ícono de información
        case "question":
            icon := 0x20 ;; Ícono de pregunta
        default:
            ;; Capturar el número de línea utilizando una excepción
            try {
                ;; Forzar una excepción para capturar el contexto de la llamada
                throw ValueError("Capturing line number", -1)
            } catch ValueError as err {
                callerLine := err.Line
            }
            icon := 0 ;; Sin ícono por defecto

            ;; Formatear el mensaje según las combinaciones de message y title
            if (message == "" and title == "") {
                message := ""
            } else if (message !== "" and title !== "") {
                message := message ':`n"' title '"'
            } else if (message == "" and title !== "") {
                message := '"' title '"'
            } else if (title !== "" and message == "") {
                message := title
            }

            title := "Line: " callerLine
    }

    ;; Si es asincrónico, usar SetTimer para mostrar el MsgBox
    if async {
        SetTimer((() => MsgBox(message, title, icon | 0x40000)), -1, -1)
        ; MsgBox async
    } else {
        ;; Mostrar el MsgBox con la opción Always On Top y el ícono seleccionado
        MsgBox(message, title, icon | 0x40000)
    }
}

/**
 * * Ejecuta un comando en PowerShell y devuelve la salida.
 * @param {String} command - El comando de PowerShell a ejecutar.
 * @param {String} [tempFolderPath=A_Temp] - (Opcional) La ruta donde se creará el archivo temporal. Por defecto, se usa la carpeta temporal del sistema.
 * @returns {Array} - Array con la salida del comando.
 */
RunPowerShellCommand(command, tempFolderPath := A_Temp) {
    tempFile := tempFolderPath "\" generateTempFileName("outPSC")

    fullCommand := "powershell -NoProfile -ExecutionPolicy Bypass -Command " "& {" command " | Out-File -FilePath " tempFile " -Encoding utf8}"

    ;; Ejecutar el comando en segundo plano
    RunWait(fullCommand, , "Hide")
    if (A_LastError !== 0) {
        showTopMsgBox("Posibles causas: `n1. PowerShell no está instalado o habilitado en el sistema.`n2. Restricciones de políticas de ejecución de scripts en PowerShell.`n`nSolución: `n1. Verifique que PowerShell está instalado y habilitado en su sistema.`n2. Revise las políticas de ejecución de PowerShell y ajuste según sea necesario.", "Error al ejecutar el comando de PowerShell", "Error", true)
        return []
    }

    ;; Leer la salida del archivo temporal
    output := []
    content := FileRead(tempFile, "UTF-8")

    for line in content.Split("`n") {
        output.Push(line.Trim("`r"))
    }

    fileDel(tempFile)
    return output
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
    if (!FileExist(path) or FileExist(path) !== "D" and FileExist(path) !== "AD" and FileExist(path) !== "RD") {
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
    data := []

    currentSection := ""  ;; Inicializa la sección actual
    inTargetSection := false  ;; Bandera para indicar si estamos en la sección objetivo
    inArray := false  ;; Bandera para indicar si estamos dentro del array

    Loop Read, pathConfigFile {
        line := Trim(A_LoopReadLine)
        ;; Ignora líneas vacías o comentarios
        if (line !== "" && SubStr(line, 1, 1) !== "#") {
            ;; Detecta el inicio de una nueva sección
            if (Trim(SubStr(line, 1, 1) = "[" && SubStr(line, -1, 1) == "]")) {
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
    return data.Unique()  ;; Elimina elementos duplicados de la lista y la devuelve
}

/**
 * * Procesa el contenido de una línea para extraer los elementos del array.
 * @param {string} lineContent - El contenido de la línea a procesar.
 * @param {Array} data - El array donde se agregarán los elementos procesados.
 * @return {boolean} - Indica si el final del array ha sido alcanzado.
 */
parseArrayContent(lineContent, data) {
    isEnd := false

    if InStr(lineContent, "[")
        lineContent := SubStr(lineContent, InStr(lineContent, "[") + 1)  ;; Extrae el contenido del array después de '['

    ;; Procesa cada elemento del array en la misma línea
    ;; Dividir el contenido en elementos separados por comas
    for index, item in StrSplit(lineContent, ",") {
        ; showTopMsgBox("lineContent[" index "]", item)

        ;; Si se encuentra un ']' sin comillas, finalizar la lectura del array
        if (SubStr(item, -1, 1) == "]") {
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

        if (item !== "") {
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
    if (isGenerating) {
        showTopMsgBox("El proceso de generación del árbol aún está en curso. Por favor, espere.", "Proceso de Generación en Curso", "Warning", true)
        return true
    }
}

/**
 * * Verifica si el checkbox de Directory Tree está activado y llama a generateDirectoryTree si es así.
 */
checkAndGenerateDirectoryTree() {
    if (directoryTreeCheckbox.Value) {
        return generateDirectoryTree()
    }
}

/**
 * * Verifica si el checkbox de Files Contents está activado y llama a generateFilesContents si es así.
 */
checkAndGenerateFilesContents() {
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
    fileConfi := confiFileTreeGen

    if (!FileExist(fileConfi)) {
        message := "El archivo requerido '" fileConfi "' no existe. Por favor, asegúrese de que el archivo está presente en el directorio adecuado y contiene datos válidos, uno por línea, sin comentarios o espacios en blanco."
        showTopMsgBox(message, "Archivo Requerido No Encontrado", "Error")
        ExitApp(1)
    }

    ;; Inicializar la GUI
    createGui()
}

/**
 * * Procesa la carpeta seleccionada, generando el árbol de directorios y/o los contenidos de los archivos.
 * @param {string} folderPath - La ruta de la carpeta.
 */
processFolder(folderPath) {
    global mainFolderPath, isGenerating, myGui, folderEdit

    if (folderPath == "")
        return

    if (checkIfGenerating()) {
        return
    }

    ;; Normalizar la ruta
    folderPath := normalizePath(folderPath)

    if (!folderPath.exist == false) {
        folderEdit.Value := folderPath.path
    }

    if (!isValidFolder(folderPath.path)) {
        showTopMsgBox("Por favor, ingrese una ruta de carpeta válida.", "Ruta de Carpeta Inválida", "Error", true)
        endGeneration()
        return
    }

    isGenerating := true
    myGui["GenerateText"].Value := "Generating..."  ;; Cambia el texto a "Generating..."

    mainFolderPath := folderPath.path


    allowedExtensions := getAllowedExtensions("AllDefault", false)
    ignoreFiles := getIgnoredFiles("AllDefault", false)

    ;; Se comprueba que folderPath.path no supere los 3.5 Megabytes
    if (getDirectorySize(folderPath.path, 3500000, ignoreFiles, allowedExtensions) == -1) {
        showTopMsgBox("Los archivos para procesar superan los 3.5 MB y no se procederá. Para solucionar esto, seleccione un directorio más pequeño o edite en el archivo de configuración los archivos que se procesarán.", "Tamaño del Directorio Excedido", "Error", true)
        endGeneration()
        return
    }

    ; if true {
    ;     endGeneration()
    ;     return
    ; }

    ;; Generar el árbol de directorios
    if (checkAndGenerateDirectoryTree()) {
        endGeneration()
        return
    }

    ;; Generar el contenido de los archivos
    if (checkAndGenerateFilesContents()) {
        endGeneration()
        return
    }

    ;; Combinar archivos y finalizar
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
    myGui["GenerateText"].Value := "Generate:"  ;; Cambia el texto de vuelta a "Generate:"
}


;todo---MARK: Files Generation


;
;
;


;;MARK:*
;^----------------Use analyzeConfigFile----------------

getAnalyzeConfigFile(section, arrayName, extendAllDefault := true) {
    if extendAllDefault
        return analyzeConfigFile(confiFileTreeGen, "AllDefault", arrayName).Extend(analyzeConfigFile(confiFileTreeGen, section, arrayName)).Unique()
    return analyzeConfigFile(confiFileTreeGen, section, arrayName).Unique()
}

getAllowedExtensions(section, extendAllDefault?) {
    allowedExtensions := getAnalyzeConfigFile(section, "allowed_extensions", extendAllDefault?)
    if (allowedExtensions.Length == 0) {
        showTopMsgBox("No se encontraron extensiones permitidas. Asegúrese de que el archivo '" confiFileTreeGen "' existe y contiene las extensiones válidas, una por línea, sin comentarios o espacios en blanco.", "No se Encontraron Extensiones Permitidas", "Error", true)
        return 1
    }
    return allowedExtensions
}

/**
 * Obtiene los archivos ignorados según la sección especificada y opcionalmente extiende todos los valores por defecto.
 * Aplica patrones de coincidencia para los nombres de archivo.
 * @param {String} section - La sección de configuración a analizar.
 * @param {Boolean} [extendAllDefault] - (Opcional) Indica si se deben extender todos los valores por defecto.
 * @returns {Array} - Devuelve un array de archivos ignorados.
 */
getIgnoredFiles(section, extendAllDefault?) {
    ignoredFiles := getAnalyzeConfigFile(section, "ignored_files", extendAllDefault?)

    newIgnoredFiles := []
    ;; Aplicar el filtro cleanPath a cada elemento de ignoredFiles
    for index, item in ignoredFiles {

        cleanItem := normalizePath(item, mainFolderPath)
        ; showTopMsgBox('normalizePath(  "' item '"  )', cleanItem.path)

        fileName := cleanItem.path.SplitPath().FileName

        ; showTopMsgBox("fileName", fileName)
        if fileName.Find("*") or fileName.Find("?") or fileName.Find("[") {
            ; showTopMsgBox("Coincidencia '*' '?' '['", item.SplitPath().FileName)
            psCommand := "Get-ChildItem -Path '" cleanItem.path "' -Filter '" fileName "' -Recurse | Select-Object -ExpandProperty FullName"

            matchFiles := RunPowerShellCommand(psCommand)

            ; showTopMsgBox(matchFiles.Join())

            newIgnoredFiles.Extend(matchFiles)

            ; showTopMsgBox(newIgnoredFiles.Join())

            continue
        }

        if (cleanItem.exist) {
            newIgnoredFiles.Push(cleanItem.path)
        }
    }

    ignoredFiles := newIgnoredFiles

    ;; Se vuelven a eliminar los duplicados porque ahora se comparan con la ruta absoluta para evitar rutas relativas repetidas.
    ignoredFiles.Unique()
    ; showTopMsgBox(ignoredFiles.Join())

    ; for index, item in ignoredFiles {
    ;     showTopMsgBox("ignoredFiles[" index "]", item)
    ; }

    return ignoredFiles
}

createDir_filesTree(allowedExtensions, ignoredFiles) {
    tempFolderPath := tempFiles.dir_filesTree

    ;; Crear una copia temporal del directorio principal con solo los archivos permitidos
    DirCreate(tempFolderPath)

    ignoreDirs := ignoredFiles
    ignoreDirs.Filter(DirExist) ;; Filtramos por directorios que existan

    Loop Files, mainFolderPath "\*.*", "R" {
        relativePath := StrReplace(A_LoopFileFullPath, mainFolderPath "\")
        fileExt := A_LoopFileExt

        ;; Verificar si el archivo o su carpeta está en la lista de ignorados
        ignoreFile := false
        for dir in ignoreDirs {
            if (InStr(A_LoopFileFullPath, dir "\") == 1) {
                ignoreFile := true
                break
            }
        }

        ;; Verificar si la extensión está en la lista de archivos permitidos y no está en la lista de archivos completos ignorados
        if !ignoreFile && allowedExtensions.HasValue(fileExt) && !ignoredFiles.HasValue(A_LoopFileFullPath) {
            destPath := tempFolderPath "\" relativePath

            ; showTopMsgBox("destPath", destPath)

            ;; Crear el directorio si no existe
            if !FileExist(StrReplace(destPath, "\*.*", "")) {
                SplitPath(destPath, , &OutDir)
                DirCreate(OutDir)
            }
            FileCopy(A_LoopFileFullPath, destPath)
        }
    }
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
 * 
 * 2. Revise las políticas de ejecución de PowerShell y ajuste según sea necesario.
 */
generateDirectoryTree() {
    temp := tempFiles.file_dirTree
    tempFolderPath := tempFiles.dir_filesTree

    ;; Obtenemos la información de los archivos requerida
    allowedExtensions := getAllowedExtensions("DirectoryTree", "allowed_extensions")
    if (allowedExtensions == 1)
        return 1 ;; Error no hay extensiones permitidas
    ignoredFiles := getIgnoredFiles("DirectoryTree", "ignored_files")

    createDir_filesTree(allowedExtensions, ignoredFiles)

    ;; Usar PowerShell para generar el árbol de archivos con caracteres Unicode correctamente
    fileTree := RunPowerShellCommand("tree /f '" tempFolderPath "'")

    ;; Una vez leido el archivo eliminamos el arbol de archivos
    dirDel(tempFolderPath)

    ;; Eliminar las dos primeras líneas
    fileTree.RemoveAt(1)
    fileTree.RemoveAt(1)

    ;; Obtener el nombre de la carpeta principal
    folderName := getCurrentFolderName(mainFolderPath)
    ;; Reemplazar la primera línea con el nombre de la carpeta principal
    fileTree[1] := folderName

    ;; Filtrar líneas vacías, eliminar espacios en blanco y tabulaciones
    fileTreeNew := "``````tree`n"
    for line in fileTree {
        if (Trim(line) !== "") {
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
    temp := tempFiles.file_filesContents
    tempFolderPath := tempFiles.dir_filesTree

    ;; Obtenemos la informacion de los archivos requerida
    allowedExtensions := getAllowedExtensions("FilesContents", "allowed_extensions")
    if (allowedExtensions == 1)
        return 1 ;; Error no hay extensiones permitidas
    ignoredFiles := getIgnoredFiles("FilesContents", "ignored_files")


    fileArray := []

    createDir_filesTree(allowedExtensions, ignoredFiles)

    Loop Files, tempFolderPath "\*.*", "R" {
        ;; Obtener la ruta relativa al directorio principal
        relativePath := StrReplace(A_LoopFileFullPath, tempFolderPath "\")

        fileArray.Push(relativePath)
    }


    if (fileArray.Length == 0) {
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
                fileList .= "#### Archivo ``" relativePath "``: `n``````````````````````````" fileExtension " `n" fileContents "`n``````````````````````````"

            if (index < fileArray.Length) {
                fileList .= "`n`n"
            }
        }
    }

    ;; Escribir los contenidos en un archivo de salida
    dirDel(tempFolderPath)
    FileAppend(fileList, temp, "UTF-8")
}


;todo---MARK: File Management

/**
 * * Elimina archivos temporales utilizados durante el procesamiento.
 */
clearTemp() {
    dirDel(tempMainDir)
}

/**
 * * Une los archivos dirTree.tmp y filesContents.tmp en uno solo según los checkboxes activados.
 * Elimina los archivos intermedios y copia el contenido final al portapapeles.
 */
mergeFiles() {
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
            fileTree := FileRead(tempFiles.file_dirTree, "UTF-8")
            outputContent .= "### Directory Tree:`n" fileTree spacer
        } catch {
            showTopMsgBox("No se pudo leer dirTree.tmp.", "Error al Leer Archivo de Árbol de Directorios", "Error", true)
        }
    }

    ;; Agregar el contenido de los archivos si está seleccionado
    if (fileContentsCheckbox.Value) {
        try {
            fileContents := FileRead(tempFiles.file_filesContents, "UTF-8")
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

    ;; Copiar el contenido final al portapapeles
    A_Clipboard := outputContent
    if !ClipWait(2) {
        showTopMsgBox("El intento de copiar texto al portapapeles falló.", "Error al Copiar al Portapapeles", "Error", true)
        return
    }

    showTopMsgBox("Información copiada al portapapeles.", "Información Copiada", "Info", true)
}


;todo---MARK: Initialization


;
;
;


;;MARK:*
;^----------------Init----------------^;

;* Inicializa el programa.
init()