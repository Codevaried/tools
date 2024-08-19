#include "../Lib/Misc/DUnit.ahk"
#include "Test_Timer.ahk"


;! Modo desarrollo: Hotkeys para recargar el script y salida rápida
#HotIf !A_IsCompiled and WinActive("ahk_exe Code.exe")
~^s:: Reload()   ;; Guarda y recarga el script
#HotIf

#HotIf !A_IsCompiled
^Esc:: ExitApp() ;; Salida de seguridad del script
#HotIf

;; Ejecutar los tests de la clase TimerTestSuite
DUnit.RunTests(TimerTestSuite)