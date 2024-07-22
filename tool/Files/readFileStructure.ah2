#Requires AutoHotkey v2.0
#SingleInstance Force
/*@Ahk2Exe-Keep
#NoTrayIcon
*/

A_MaxHotkeysPerInterval := 1000

KeyHistory 0
ListLines 0
SetWinDelay 0
SetKeyDelay -1, -1

;! Uso solo para modo desarollo
~^s:: Reload ; Guardar y recargar el script

global isGenerating := false ; Bandera para evitar ejecuciones concurrentes

/**
 * Crear una GUI para generar un árbol de archivos de un directorio arrastrado.
 */
CreateGui() {
    global MyGui, FolderEdit, FolderButton, DirectoryTreeCheckbox, FileContentsCheckbox
    MyGui := Gui("+AlwaysOnTop", "Generador de Árbol de Archivos")
    MyGui.SetFont("s10", "Segoe UI")

    ; Añadir controles a la GUI
    MyGui.Add("Text", , "Arrastre una carpeta o selecciónela manualmente:")
    FolderEdit := MyGui.Add("Edit", "w400 vFolderPath")
    FolderButton := MyGui.Add("Button", "xp+263 y+5", "Seleccionar Carpeta")

    ; Añadir texto "Generate:" con tamaño más grande y ajustar su posición y ancho
    MyGui.Add("Text", "xm yp+10 w100", "Generate:").SetFont("s12", "Segoe UI")

    ; Añadir CheckBoxes en línea y activarlos por defecto
    DirectoryTreeCheckbox := MyGui.Add("CheckBox", "xm y+5 Checked", "Directory Tree")
    FileContentsCheckbox := MyGui.Add("CheckBox", "x+10 Checked", "Files Contents")

    ; Configurar eventos de botones y checkboxes
    FolderButton.OnEvent("Click", SelectFolder)
    DirectoryTreeCheckbox.OnEvent("Click", EnsureOneCheckboxChecked)
    FileContentsCheckbox.OnEvent("Click", EnsureOneCheckboxChecked)

    ; Configurar evento de arrastre
    MyGui.OnEvent("DropFiles", GuiDropFiles)

    ; Configurar la captura de la tecla Enter
    OnMessage(0x0100, WM_KEYDOWN)

    ; Mostrar la GUI centrada
    MyGui.Show("AutoSize Center")
}

/**
 * Asegura que al menos uno de los checkboxes esté activado.
 */
EnsureOneCheckboxChecked(*) {
    global DirectoryTreeCheckbox, FileContentsCheckbox
    if (!DirectoryTreeCheckbox.Value && !FileContentsCheckbox.Value) {
        DirectoryTreeCheckbox.Value := true
    }
}

/**
 * Selecciona una carpeta mediante un diálogo.
 */
SelectFolder(*) {
    global FolderEdit
    if (CheckIfGenerating())
        return
    FolderPath := DirSelect()
    if (FolderPath) {
        FolderEdit.Value := NormalizePath(FolderPath)
        ProcessFolder(FolderEdit.Value)
    }
}

/**
 * Normaliza una ruta de archivo reemplazando todas las barras "/" con "\" y eliminando cualquier barra inicial o final.
 * @param {string} Path - La ruta a normalizar.
 * @return {string} - La ruta normalizada.
 */
NormalizePath(Path) {
    Path := StrReplace(Path, "/", "\")
    while (SubStr(Path, 1, 1) = "\" or SubStr(Path, 1, 1) = "/") {
        Path := SubStr(Path, 2)
    }
    while (SubStr(Path, -1) = "\" or SubStr(Path, -1) = "/") {
        Path := SubStr(Path, 1, -1)
    }
    return ValidateFolder(Path)
}

/**
 * Valida si una ruta es una carpeta válida.
 * @param {string} Path - La ruta a validar.
 * @return {string|false} - La ruta validada si es válida, de lo contrario, false.
 */
ValidateFolder(Path) {
    if (!FileExist(Path) or FileExist(Path) != "D" and FileExist(Path) != "AD" and FileExist(Path) != "RD") {
        ShowTopMsgBox("Error", "Por favor, ingrese una ruta de carpeta válida.", "Error")
        return false
    }
    return Path
}

/**
 * Obtiene el nombre de la carpeta principal de una ruta.
 * @param {string} FolderPath - La ruta de la carpeta.
 * @return {string} - El nombre de la carpeta principal.
 */
GetMainFolderName(FolderPath) {
    originalDir := A_WorkingDir
    SetWorkingDir(FolderPath)
    mainFolder := RegExReplace(A_WorkingDir, "^.*\\")
    SetWorkingDir(originalDir)
    return mainFolder
}

/**
 * Verifica si el proceso de generación está en curso y muestra un mensaje si es así.
 * @return {boolean} - Verdadero si el proceso está en curso, falso en caso contrario.
 */
CheckIfGenerating() {
    global isGenerating
    if (isGenerating) {
        ShowTopMsgBox("Advertencia", "El proceso de generación del árbol aún está en curso. Por favor, espere.", "Warning")
        return true
    }
    return false
}

/**
 * Procesa la carpeta seleccionada, generando el árbol de directorios y/o los contenidos de los archivos.
 * @param {string} FolderPath - La ruta de la carpeta.
 */
ProcessFolder(FolderPath) {
    global isGenerating
    if (CheckIfGenerating())
        return
    ; SoundBeep()
    isGenerating := true

    ; Normalizar la ruta
    FolderPath := NormalizePath(FolderPath)
    if (!FolderPath) {
        isGenerating := false
        return
    }

    CheckAndGenerate_DirectoryTree(FolderPath)
    CheckAndGenerate_FilesContents(FolderPath)
    CopyToClipboard()
    isGenerating := false
}

/**
 * Verifica si el checkbox de Directory Tree está activado y llama a GenerateDirectoryTree si es así.
 * @param {string} FolderPath - La ruta de la carpeta.
 */
CheckAndGenerate_DirectoryTree(FolderPath) {
    global DirectoryTreeCheckbox
    if (DirectoryTreeCheckbox.Value) {
        GenerateDirectoryTree(FolderPath)
    }
}

/**
 * Verifica si el checkbox de Files Contents está activado y llama a GenerateFilesContents si es así.
 * @param {string} FolderPath - La ruta de la carpeta.
 */
CheckAndGenerate_FilesContents(FolderPath) {
    global FileContentsCheckbox
    if (FileContentsCheckbox.Value) {
        GenerateFilesContents(FolderPath)
    }
}

/**
 * Genera el árbol de archivos de la carpeta seleccionada.
 * @param {string} FolderPath - La ruta de la carpeta.
 */
GenerateDirectoryTree(FolderPath) {

    ; Usar PowerShell para generar el árbol de archivos con caracteres Unicode correctamente
    Command := "powershell -NoProfile -ExecutionPolicy Bypass -Command " "& {tree /f '" FolderPath "' | Out-File -FilePath tree_output.tree -Encoding utf8}"
    RunWait(Command, , "Hide")
    if (A_LastError) {
        MsgBox("+AlwaysOnTop Error al generar el árbol de archivos. Por favor, intente nuevamente.")
        return
    }

    ; Leer el archivo de salida y eliminar las dos primeras líneas
    FileTree := FileRead("tree_output.tree", "UTF-8")
    FileTreeArray := StrSplit(FileTree, "`n")
    ; Eliminar las dos primeras líneas
    FileTreeArray.RemoveAt(1)
    FileTreeArray.RemoveAt(1)

    ; Obtener el nombre de la carpeta principal
    FolderName := GetMainFolderName(FolderPath)

    ; Reemplazar la primera línea con el nombre de la carpeta principal
    FileTreeArray[1] := FolderName
    ; Filtrar líneas vacías y eliminar espacios en blanco y tabulaciones
    FileTreeNew := ""
    for line in FileTreeArray {
        if (StrLen(Trim(line)) > 0) {
            FileTreeNew .= line "`n"
        }
    }
    ; Reescribir el archivo con las modificaciones
    FileDelete("tree_output.tree")
    FileAppend(FileTreeNew, "tree_output.tree", "UTF-8")

    ; Mostrar mensaje de confirmación
    ; MsgBox("Árbol de archivos guardado en tree_output.tree")
}

/**
 * Verifica si un valor está en una lista.
 * @param {Array} list - La lista a verificar.
 * @param {string} value - El valor a buscar.
 * @return {boolean} - Verdadero si el valor está en la lista, falso en caso contrario.
 */
HasValue(list, value) {
    for item in list {
        if (item = value)
            return true
    }
    return false
}

/**
 * Lee las extensiones permitidas desde un archivo.
 * @param {string} FilePath - La ruta del archivo que contiene las extensiones permitidas.
 * @return {Array} - Una lista de extensiones permitidas.
 */
LoadAllowedExtensions(FilePath) {
    if !FileExist(FilePath) {
        ShowTopMsgBox("Error", "El archivo de extensiones permitidas no existe.", "Error")
        return []
    }
    Extensions := []
    Loop Read, FilePath {
        Extension := Trim(A_LoopReadLine)
        if (Extension != "" && SubStr(Extension, 1, 1) != "#") ; Ignorar comentarios y líneas vacías
            Extensions.Push(Extension)
    }
    return Extensions
}

/**
 * Genera el contenido de los archivos de la carpeta seleccionada.
 * @param {string} FolderPath - La ruta de la carpeta.
 */
GenerateFilesContents(FolderPath) {
    FileList := ""
    AllowedExtensions := LoadAllowedExtensions("AllowedExtensions.txt") ; Cargar extensiones permitidas desde archivo
    if (AllowedExtensions.Length = 0) {
        ShowTopMsgBox("Error", "No se encontraron extensiones permitidas.", "Error")
        return
    }

    MainFolder := GetMainFolderName(FolderPath)
    FileArray := []
    Loop Files, FolderPath "\*.*", "R" {
        ; Obtener la ruta relativa al directorio principal
        RelativePath := StrReplace(A_LoopFileFullPath, FolderPath "\")
        ; Obtener la extensión del archivo
        FileExt := StrLower(StrSplit(A_LoopFileFullPath, ".").Pop())
        ; Verificar si la extensión está en la lista de archivos permitidos
        if HasValue(AllowedExtensions, FileExt) {
            FileArray.Push(RelativePath)
        }
    }

    for index, RelativePath in FileArray {
        try {
            FileContents := FileRead(FolderPath "\" RelativePath, "UTF-8")
            ErrorFileContents := false
        } catch {
            FileContents := ""
            ErrorFileContents := true
        }

        if (ErrorFileContents)
            FileList .= "Archivo '" RelativePath " '[Error Lectura del archivo]"
        else
            FileList .= "Archivo '" RelativePath "': `n" FileContents

        if (index < FileArray.Length) {
            FileList .= "`n`n"
        }
    }

    ; Escribir los contenidos en un archivo de salida
    if FileExist("files_contents_output.txt")
        FileDelete("files_contents_output.txt")
    FileAppend(FileList, "files_contents_output.txt", "UTF-8")

    ; Mostrar mensaje de confirmación
    ; MsgBox("Contenido de los archivos guardado en files_contents_output.txt")
}

/**
 * Copia la información generada al portapapeles según los checkboxes seleccionados.
 */
CopyToClipboard() {
    global DirectoryTreeCheckbox, FileContentsCheckbox
    Clipboard := ""  ; Limpia el portapapeles
    ClipWait(1, 0)  ; Espera hasta que el portapapeles esté vacío, con un timeout de 1 segundo

    ; Genera el contenido a copiar
    ClipboardContent := ""
    if (DirectoryTreeCheckbox.Value) {
        FileTree := FileRead("tree_output.tree", "UTF-8")
        ClipboardContent .= "### Estructura de Archivos:`n" FileTree "`n`n"
    }
    if (FileContentsCheckbox.Value) {
        FileContents := FileRead("files_contents_output.txt", "UTF-8")
        ClipboardContent .= "### Contenido de los Archivos:`n" FileContents "`n`n"
    }

    ; Asigna el contenido al portapapeles
    A_Clipboard := ClipboardContent
    if !ClipWait(2) {
        ShowTopMsgBox("Error", "El intento de copiar texto al portapapeles falló.", "Error")
        return
    }
    ShowTopMsgBox("Información", "Información copiada al portapapeles.", "Info")
}

/**
 * Maneja el evento de arrastre de archivos a la GUI.
 * @param {object} thisGui - La GUI donde se soltaron los archivos.
 * @param {object} Ctrl - El control donde se soltaron los archivos.
 * @param {array} FileArray - Lista de archivos arrastrados.
 */
GuiDropFiles(thisGui, Ctrl, FileArray, *) {
    global FolderEdit
    if (CheckIfGenerating())
        return
    FolderPath := NormalizePath(FileArray[1])
    if (FolderPath) { ; Verificar si la ruta es válida
        FolderEdit.Value := FolderPath
        ProcessFolder(FolderEdit.Value)
    }
}

/**
 * Maneja el evento de tecla presionada.
 * @param {WPARAM} wParam - El código de la tecla presionada.
 * @param {LPARAM} lParam - Información adicional sobre la tecla presionada.
 * @param {MSG} msg - El mensaje de la tecla presionada.
 * @param {HWND} hwnd - El identificador de la ventana.
 */
WM_KEYDOWN(wParam, lParam, msg, hwnd) {
    global FolderEdit
    if (CheckIfGenerating())
        return
    if (wParam = 0x0D) { ; Código de la tecla Enter
        if (WinActive("Generador de Árbol de Archivos")) {
            ProcessFolder(FolderEdit.Value)
        }
    }
}

/**
 * Muestra un MsgBox siempre en la parte superior con un ícono según el tipo de mensaje.
 * @param {string} title - El título del MsgBox.
 * @param {string} message - El mensaje a mostrar en el MsgBox.
 * @param {string} type - El tipo de mensaje (Error, Warning, Info, Question).
 */
ShowTopMsgBox(title, message, type := "Info") {
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

CreateGui()