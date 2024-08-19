#Requires AutoHotkey v2.0


/**
 * * Función renovada para controlar el flujo de ejecución de una Hotkey y solucionar el problema del bloqueo de mayúsculas al enviar un input dentro de un bucle.
 * 
 * @param {String} ThisHotkey - La Hotkey específica a manipular.
 * @param {String} BlockLabel - La función que se ejecutará al activar la Hotkey.
 * @param {Boolean} [CapsLockAlwaysOff=false] - Indica si el bloqueo de mayúsculas debe permanecer desactivado después de ejecutar la función.
 * @param {String|Boolean} [MainBlockLabel=false] - La función principal creada con el comando "Hotkey". Si se proporciona, se usará para denegar cualquier input repetido de la tecla presionada.
 * @param {Boolean} [ModeKeyWait=false] - Indica si se debe esperar a que la tecla iniciadora deje de estar presionada para ejecutar la "BlockLabel".
 * @returns {String} - La Hotkey especificada.
 * 
 * @remarks
 * - La variable `ThisHotkey` no puede ser igual a "CapsLock" ni a cualquier otra variedad de prefijo ("~", "*", "~*"), por ejemplo "~*CapsLock".
 * - Se recomienda establecer correctamente la función `HotKeyBlock_HotKeyNull()` en el script para el correcto funcionamiento de esta función.
 * - Es obligatorio establecer al principio del script una de las opciones proporcionadas para denegar la entrada de la tecla "Principal"/"Iniciadora".
 */
HotKeyBlock(ThisHotkey, BlockLabel, CapsLockAlwaysOff := false, MainBlockLabel := False, ModeKeyWait := false) {
    ;; Cambiar "HotIfWinActive" en caso de otro programa activo
    HotIfWinActive
    Hotkey ThisHotkey, "Off"
    If (!MainBlockLabel) {
    } Else {
        Hotkey ThisHotkey, HotKeyBlock_HotKeyNull
        Hotkey ThisHotkey, "On"
    }

    HotIfWinActive
    LastCapsLock := false
    Hotkey "*CapsLock", "On"
    if (GetKeyState("CapsLock", "T")) {
        SetCapsLockState "Off"
        LastCapsLock := true
    }

    If (ModeKeyWait)
        KeyWait ThisHotkey
    SoundBeep 523
    %BlockLabel%()

    ;; Cambiar "HotIfWinActive" en caso de otro programa activo
    HotIfWinActive
    Hotkey ThisHotkey, "On"
    If (!MainBlockLabel) {
    } Else {
        Hotkey ThisHotkey, %MainBlockLabel%
        Hotkey ThisHotkey, "On"
    }

    HotIfWinActive

    If (!CapsLockAlwaysOff) {
        if (LastCapsLock)
            SetCapsLockState "On"
    }
    Hotkey "*CapsLock", "Off"

    return ThisHotkey
}


/**
 * * Función para denegar/anular la entrada de la tecla "Principal"/"Iniciadora".
 * 
 * @param {String} HotkeyName - Nombre de la Hotkey.
 * 
 * @remarks
 * Configuración al principio del script
 * 
 * Para el correcto funcionamiento de la función HotKeyBlock(), es necesario establecer la siguiente configuración al principio del script:
 * 
 * Opción 1:
 *   ```
 *   HotIfWinActive
 *   Hotkey "*CapsLock", HotKeyBlock_HotKeyNull
 *   Hotkey "*CapsLock", "Off"
 *   ```
 *   Esta opción desactiva la Hotkey "*CapsLock" y establece la función HotKeyBlock_HotKeyNull() para denegar la entrada de la tecla "Principal"/"Iniciadora".
 * 
 * Opción 2:
 *   ```
 *   HotIfWinActive
 *   Hotkey "*CapsLock", "Off"
 *   *CapsLock::return
 *   ```
 *   Esta opción simplemente desactiva la Hotkey "*CapsLock".
 * 
 * Ambas opciones logran el mismo resultado y pueden ser utilizadas según las necesidades del script.
 */
HotKeyBlock_HotKeyNull(HotkeyName) {
    return
}