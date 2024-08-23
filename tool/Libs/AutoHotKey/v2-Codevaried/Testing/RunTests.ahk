#Requires AutoHotkey v2.0

#include "../Lib/Misc/DUnit.ahk"


#include "Test_DUnit.ahk"

#include "Test_Misc.ahk"

#include "Test_Array.ahk"
#include "Test_Map.ahk"
#include "Test_String.ahk"

#include "Test_Timer.ahk"


;! Modo desarrollo: Hotkeys para recargar el script y salida rápida
#HotIf !A_IsCompiled and WinActive("ahk_exe Code.exe")
~^s:: Reload()   ;; Guarda y recarga el script
#HotIf

#HotIf !A_IsCompiled
^Esc:: ExitApp() ;; Salida de seguridad del script
#HotIf


RunTests() {
    DUnit.SetOptions("+V +F")
    if DUnit.RunTests(DUnitTestSuite).errors
        return 1 ;; Aborted


    DUnit.SetOptions("+V -F")
    if DUnit.RunTests(MiscTestSuite).errors
        return 1 ;; Aborted


    DUnit.SetOptions("+V -F")
    DUnit.RunTests(ArrayTestSuite, MapTestSuite, StringTestSuite)


    DUnit.SetOptions("+V -F")
    DUnit.RunTests(TimerTestSuite)
}

if RunTests()
    Print(A_ScriptName ":RunTests -> Aborted", "#FAIL")