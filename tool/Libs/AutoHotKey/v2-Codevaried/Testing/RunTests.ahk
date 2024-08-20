#include "../Lib/Misc/DUnit.ahk"
#include "Test_Timer.ahk"
#include "Test_DUnit.ahk"


;! Modo desarrollo: Hotkeys para recargar el script y salida rápida
#HotIf !A_IsCompiled and WinActive("ahk_exe Code.exe")
~^s:: Reload()   ;; Guarda y recarga el script
#HotIf

#HotIf !A_IsCompiled
^Esc:: ExitApp() ;; Salida de seguridad del script
#HotIf


DUnit.SetOptions("+V") ;; Establece Verbose en true

;; Ejecutar los tests de la clase DUnitTestSuite y TimerTestSuite
DUnit.RunTests(DUnitTestSuite, TimerTestSuite)