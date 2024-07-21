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
        FolderEdit.Value := FolderPath
        GenerateTree(FolderPath)
    }
}

/**
 * Función para generar el árbol de archivos de la carpeta seleccionada.
 * @param {string} FolderPath - La ruta de la carpeta.
 */
GenerateTree(FolderPath) {
    ; Usar PowerShell para generar el árbol de archivos con caracteres Unicode correctamente
    Command := "powershell -NoProfile -ExecutionPolicy Bypass -Command " "& {tree /f '" FolderPath "' | Out-File -FilePath tree_output.txt -Encoding utf8}"
    RunWait(Command)

    ; Leer el archivo de salida y eliminar las dos primeras líneas
    FileTree := FileRead("tree_output.txt", "UTF-8")
    FileTreeArray := StrSplit(FileTree, "`n")
    ; Eliminar las dos primeras líneas
    FileTreeArray.RemoveAt(1)
    FileTreeArray.RemoveAt(1)
    ; Obtener el nombre de la carpeta principal
    FolderName := StrSplit(FolderPath, "\").Pop()
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
    FileDelete("tree_output.txt")
    FileAppend(FileTreeNew, "tree_output.txt", "UTF-8")

    ; Mostrar mensaje de confirmación
    MsgBox("Árbol de archivos guardado en tree_output.txt")
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
        FolderEdit.Value := FolderPath
        GenerateTree(FolderPath)
    } else {
        MsgBox("Por favor, arrastre una carpeta válida.")
    }
}

CreateGui()