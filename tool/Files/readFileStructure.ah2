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

~^s:: Reload ;# Guardar y recargar el script

/**
 * Crear una GUI para generar un árbol de archivos de un directorio arrastrado.
 */
CreateGui() {
    global MyGui, FolderEdit, FolderButton
    MyGui := Gui(, "Generador de Árbol de Archivos")
    MyGui.SetFont("s10", "Segoe UI")

    ; Añadir controles a la GUI
    MyGui.Add("Text", , "Arrastre una carpeta o selecciónela manualmente:")
    FolderEdit := MyGui.Add("Edit", "w400 vFolderPath")
    FolderButton := MyGui.Add("Button", , "Seleccionar Carpeta")

    ; Configurar eventos de botones
    FolderButton.OnEvent("Click", SelectFolder)

    ; Configurar evento de arrastre
    MyGui.OnEvent("DropFiles", GuiDropFiles)

    ; Configurar la captura de la tecla Enter
    OnMessage(0x0100, WM_KEYDOWN)

    ; Mostrar la GUI centrada
    MyGui.Show("AutoSize Center")
}

/**
 * Función para seleccionar una carpeta mediante un diálogo.
 */
SelectFolder(*) {
    global FolderEdit
    FolderPath := DirSelect()
    if (FolderPath) {
        FolderEdit.Value := NormalizePath(FolderPath)
        GenerateTree(FolderPath)
    }
}

/**
 * Función para normalizar una ruta de archivo.
 * Reemplaza todas las barras "/" con "\" y elimina cualquier barra inicial o final.
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
    return Path
}

/**
 * Función para obtener el nombre de la carpeta principal de una ruta.
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
 * Función para generar el árbol de archivos de la carpeta seleccionada.
 * @param {string} FolderPath - La ruta de la carpeta.
 */
GenerateTree(FolderPath) {
    ; Normalizar la ruta
    FolderPath := NormalizePath(FolderPath)

    ; Validar que la ruta es válida
    if (!FileExist(FolderPath) or FileExist(FolderPath) != "D" and FileExist(FolderPath) != "AD" and FileExist(FolderPath) != "RD") {
        MsgBox("Por favor, ingrese una ruta de carpeta válida.")
        return
    }

    ; Usar PowerShell para generar el árbol de archivos con caracteres Unicode correctamente
    Command := "powershell -NoProfile -ExecutionPolicy Bypass -Command " "& {tree /f '" FolderPath "' | Out-File -FilePath tree_output.tree -Encoding utf8}"
    RunWait(Command, , "Hide")
    if (A_LastError) {
        MsgBox("Error al generar el árbol de archivos. Por favor, intente nuevamente.")
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
    FileTreeNew := "### Estructura de Archivos:`n"
    for line in FileTreeArray {
        if (StrLen(Trim(line)) > 0) {
            FileTreeNew .= line "`n"
        }
    }
    ; Reescribir el archivo con las modificaciones
    FileDelete("tree_output.tree")
    FileAppend(FileTreeNew, "tree_output.tree", "UTF-8")

    ; Mostrar mensaje de confirmación
    MsgBox("Árbol de archivos guardado en tree_output.tree")
}

/**
 * Función para manejar el evento de arrastre de archivos a la GUI.
 * @param {object} thisGui - La GUI donde se soltaron los archivos.
 * @param {object} Ctrl - El control donde se soltaron los archivos.
 * @param {array} FileArray - Lista de archivos arrastrados.
 */
GuiDropFiles(thisGui, Ctrl, FileArray, *) {
    global FolderEdit
    FolderPath := FileArray[1]
    if (FileExist(FolderPath) = "D") {
        FolderEdit.Value := NormalizePath(FolderPath)
        GenerateTree(FolderPath)
    } else {
        MsgBox("Por favor, arrastre una carpeta válida.")
    }
}

/**
 * Función para manejar el evento de tecla presionada.
 * @param {WPARAM} wParam - El código de la tecla presionada.
 * @param {LPARAM} lParam - Información adicional sobre la tecla presionada.
 * @param {MSG} msg - El mensaje de la tecla presionada.
 * @param {HWND} hwnd - El identificador de la ventana.
 */
WM_KEYDOWN(wParam, lParam, msg, hwnd) {
    global FolderEdit
    if (wParam = 0x0D) { ; Código de la tecla Enter
        if (WinActive("Generador de Árbol de Archivos")) {
            GenerateTree(FolderEdit.Value)
        }
    }
}

CreateGui()