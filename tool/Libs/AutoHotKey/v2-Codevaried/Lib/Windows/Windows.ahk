#Requires AutoHotkey v2.0

#Include "CustomizedGUI.ahk"


;todo---MARK: Class Window:

/**
 * Clase para gestionar operaciones comunes en ventanas.
 */
class Window {
    static winTitleGet := "A"

    /**
     * * Obtiene el título de la ventana activa.
     * @returns {String} El título de la ventana activa.
     */
    static winTitle {
        get => WinGetTitle(this.winTitleGet)
    }

    /**
     * * Obtiene el texto de la ventana activa.
     * @returns {String} El texto de la ventana activa.
     */
    static winText {
        get => WinGetText(this.winTitleGet)
    }

    /**
     * * Obtiene la ruta del ejecutable del proceso de la ventana activa.
     * @returns {String} La ruta del ejecutable del proceso.
     */
    static exePath {
        get => WinGetProcessPath(this.winTitleGet)
    }

    /**
     * * Obtiene el nombre del proceso de la ventana activa.
     * @returns {String} El nombre del proceso.
     */
    static processExe {
        get => WinGetProcessName(this.winTitleGet)
    }

    /**
     * * Obtiene la clase de la ventana activa.
     * @returns {String} La clase de la ventana.
     */
    static class {
        get => WinGetClass(this.winTitleGet)
    }

    /**
     * * Obtiene el ID de la ventana activa.
     * @returns {String} El ID de la ventana.
     */
    static ID {
        get => WinGetID(this.winTitleGet)
    }

    /**
     * * Obtiene el PID del proceso de la ventana activa.
     * @returns {String} El PID del proceso.
     */
    static tPID {
        get => WinGetPID(this.winTitleGet)
    }

    /**
     * * Obtiene un nombre descriptivo para la ventana activa.
     * @returns {String} El nombre descriptivo de la ventana.
     */
    static winName() {
        local title := this.winTitle.Trim()
        title := title != "" ? title : ""
        return this.processExe[1, -5] " -> " title
    }

    /**
     * * Establece el nivel de transparencia de la ventana activa por un incremento especificado.
     * 
     * @param {String} opc - La operación a realizar. Usa "+" para aumentar la transparencia y "-" para disminuir.
     * @param {Integer} [increment=1] - La cantidad por la cual cambiar el nivel de transparencia. El valor predeterminado es 1.
     * @example
     * Window.SetTransDegree("+")  ; Aumenta el nivel de transparencia en el incremento predeterminado de 1.
     * Window.SetTransDegree("-", 10)  ; Disminuye el nivel de transparencia en 10.
     */
    static SetTransDegree(opc, increment := 1) {
        local MouseWin, TransDegree
        MouseGetPos , , &MouseWin
        TransDegree := (WinGetTransparent(MouseWin) = "") ? 255 : WinGetTransparent(MouseWin)
        if (opc = "-") {
            TransDegree := Min(255, TransDegree + increment)
        } else if (opc = "+") {
            TransDegree := Max(1, TransDegree - increment)
        }
        WinSetTransparent(" " TransDegree, MouseWin)
        local TransDegreeInfo := Format("{:d}", 100 - ((TransDegree / 256) * 100)) "%"
        ToolTip("Transparent: " TransDegreeInfo)
        SetTimer () => ToolTip(), -1000
    }

    /**
     * * Establece la ventana activa para que esté siempre encima o no.
     * 
     * @param {Boolean} [action] - Si es true, establece la ventana como siempre encima. Si es false, establece la ventana para que no esté siempre encima.
     * @param {Boolean} [popUp=false] - Si es true, muestra una notificación emergente con el estado.
     * @example
     * Window.SetAlwaysOnTop(true)  // Establece la ventana activa como siempre encima.
     * Window.SetAlwaysOnTop(false)  // Establece la ventana activa para que no esté siempre encima.
     */
    static SetAlwaysOnTop(action?, popUp := false) {
        if IsSet(action) {
            if (action) {
                WinSetAlwaysOnTop(1, "A")
                _OnOff(true)
                Window._SoundBeep(false)
            } else {
                WinSetAlwaysOnTop(0, "A")
                _OnOff(false)
                Window._SoundBeep(true)
            }
        } else {
            WinSetAlwaysOnTop(-1, "A")
            if Window._IsWindowAlwaysOnTop() {
                _OnOff(true)
                Window._SoundBeep(true)
            } else {
                _OnOff(false)
                Window._SoundBeep(false)
            }
        }

        _OnOff(state) {
            if (popUp) {
                local timer := 3000
                local text := state ? " (ON)" : " (OFF)"
                CustomGUI.info(this.winName() text, "Dark", timer)
            }
        }
    }

    /**
     * * Verifica si la ventana activa está establecida como siempre encima.
     * 
     * @returns {Boolean} - True si la ventana activa está establecida como siempre encima, false en caso contrario.
     * @private
     */
    static _IsWindowAlwaysOnTop() {
        ExStyle := WinGetExStyle("A")
        return (ExStyle & 0x8)  ; 0x8 es WS_EX_TOPMOST
    }

    /**
     * * Emite un sonido de beep basado en la condición proporcionada.
     * 
     * @param {Boolean} on - Si es true, emite un sonido de tono alto. Si es false, emite un sonido de tono bajo.
     * @private
     */
    static _SoundBeep(on) => SetTimer(() => SoundBeep(on ? 500 : 300, 200), -1)
}