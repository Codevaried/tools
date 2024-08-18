/**
 * Copia el texto seleccionado al portapapeles.
 * @remarks Limpia el portapapeles antes de copiar y espera hasta 3 segundos para que el portapapeles tenga contenido.
 */
Copy() {
	A_Clipboard := ""
	Send("^{Insert}")
	ClipWait(3, 1)
}

/**
 * Pega el texto desde el portapapeles.
 */
Paste() => Send("+{Insert}")

/**
 * Pega el texto desde el portapapeles utilizando el atajo de Windows.
 */
WinPaste() => Send("#v")

/**
 * Corta el texto seleccionado al portapapeles.
 * @remarks Limpia el portapapeles antes de cortar y espera hasta 3 segundos para que el portapapeles tenga contenido.
 */
Cut() {
	A_Clipboard := ""
	Send("^x")
	ClipWait(3, 1)
}

/**
 * Selecciona todo el texto.
 */
SelectAll() => Send("^a")

/**
 * Deshace la última acción.
 */
Undo() => Send("^z")

/**
 * Rehace la última acción deshecha.
 */
Redo() => Send("^y")

/**
 * Cierra la pestaña actual.
 */
CloseTab() => Send("^w")

/**
 * Abre una nueva pestaña.
 */
NewTab() => Send("^t") ;; VScode: ^n

/**
 * Cambia a la siguiente pestaña.
 */
NextTab() => Send("^{PgDn}")

/**
 * Cambia a la pestaña anterior.
 */
PrevTab() => Send("^{PgUp}")

/**
 * Cambia a la siguiente aplicación utilizando Alt+Tab.
 */
AltTab() => Send("^!{Tab}")

/**
 * Guarda el documento actual.
 */
Save() => Send("^s")

/**
 * Restaura la última pestaña cerrada.
 */
RestoreTab() => Send("^+t")

/**
 * Elimina la palabra a la izquierda del cursor.
 */
DeleteWord() => Send("{Ctrl down}{Left}{Delete}{Ctrl up}")