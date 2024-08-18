#Requires AutoHotkey v2.0.0+
#SingleInstance Force

;; Incluir otras librerías necesarias
#include "../../../Lib/Tools/Highlight.ahk"

;! Uso solo para modo desarrollo
#HotIf !A_IsCompiled and WinActive("ahk_exe Code.exe")
^s:: {
    Send("^s")  ;; Simula Ctrl+S para guardar el archivo
    Sleep(100)  ;; Pequeño retraso para asegurar que el archivo se guarde
    Reload()    ;; Recarga el script
}
#HotIf

#HotIf !A_IsCompiled
^Esc:: ExitApp(1) ;; Salida de seguridad del script
#HotIf


;; Variables para el estado del seguimiento
global followMouseEnabled := false

;* Ctrl + Shift: Activar seguimiento del mouse
^Shift:: {
    global followMouseEnabled
    if !followMouseEnabled {
        FollowMouse()
        followMouseEnabled := true
    }
}

;* Ctrl + Shift (soltar): Desactivar seguimiento del mouse
^Shift up:: {
    global followMouseEnabled
    if followMouseEnabled {
        FollowMouse()  ;; Esto limpia el seguimiento del mouse
        followMouseEnabled := false
    }
}

; ~LButton:: {
;     ; MouseTip()
;     SetTimer(MouseTip, -1)
; }
