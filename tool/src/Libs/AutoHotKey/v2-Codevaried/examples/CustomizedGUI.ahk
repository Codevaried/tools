#Requires AutoHotkey v2.0.0+
#SingleInstance Force
; #Warn All, MsgBox
#Warn All, Off

SetKeyDelay -1

#Include "..\Lib\Windows\CustomizedGUI.ahk"


;? MAIN HOTKEY:

^Esc:: ExitApp ;; Salida de seguridad del script

#HotIf Winactive("ahk_exe Code.exe")
~^s:: Reload ;; Guardar y recargar el script
#HotIf


goto INIT

;?  Ejemplo de uso de la biblioteca CustomGUI en AutoHotKey v2

INIT:

    CustomGUI.Set_PopUp.Set_MaxWidthInChars("Text", 10)


    Title := "Title"
    SubTitle := "SubTitle"
    Text := "Text"
    TimeOut := 0
    ; CustomGUI.PopUp(Text, , , Theme:="Dark", Pos:="Top", TimeOut)
    CustomGUI.PopUp(Text, Title, SubTitle, Theme := "Dark", Pos := "x1085 y54", TimeOut)
    CustomGUI.PopUp("4", "5", "8", Theme := "Dark", Pos := "RTop", TimeOut)

    Title := "OXXXXXXXXXXXXXXXO"
    SubTitle := "OXXXXXXXXXXXXXXXXXXXXXO"
    Text := "OXXXXXXXXXXXXXXXXXXXXXXXXXXXXOOXXXXXXXXXXXXXXXXXXXXXXXXXXXXOOXXXXXXXXXXXXXXXXXXXXXXXXXXXXO"
    ; CustomGUI.PopUp(Text, , , Theme:="Dark", Pos:="Top", TimeOut)
    CustomGUI.PopUp(Text, Title, SubTitle, Theme := "Dark", Pos := "x1085 y403", TimeOut)
    CustomGUI.PopUp("30 x 3 = 90", "17", "23", Theme := "Dark", Pos := "RCenter", TimeOut)

    Title := "OXXXXXXXXXXXXXXXOOXXXXXXXXXXXXXXXO"
    SubTitle := "OXXXXXXXXXXXXXXXXXXXXXOOXXXXXXXXXXXXXXXXXXXXXO"
    Text := "OXXXXXXXXXXXXXXXXXXXXXXXXXXXXOOXXXXXXXXXXXXXXXXXXXXXXXXXXXXOOXXXXXXXXXXXXXXXXXXXXXXXXXXXXOOXXXXXXXXXXXXXXXXXXXXXXXXXXXXOOXXXXXXXXXXXXXXXXXXXXXXXXXXXXOOXXXXXXXXXXXXXXXXXXXXXXXXXXXXO"
    ; CustomGUI.PopUp(Text, , , Theme:="Dark", Pos:="Top", TimeOut)
    CustomGUI.PopUp(Text, Title, SubTitle, Theme := "Dark", Pos := "x1085 y783", TimeOut)
    CustomGUI.PopUp("30 x 6 = 180", "34", "46", Theme := "Dark", Pos := "RBelow", TimeOut)

    Title := "fefeffefefeeffefefe"
    SubTitle := "fsffefefewf"
    Text := "fafafeffafafafafefewf`ndffefefefewf`ndffefefafafefewf`ndffefefafafefewf`ndffefeewf`ndffefe"
    ; CustomGUI.PopUp(Text, , , Theme:="Dark", Pos:="Top", TimeOut)
    CustomGUI.PopUp(Text, Title, SubTitle, Theme := "Dark", Pos := "x682 y54", TimeOut)


    Title := "fefeffefefeeffefefe"
    SubTitle := "fsffefefewf"
    Text := "ferfrefrfreferfrefref"
    ; CustomGUI.PopUp(Text, , , Theme:="Dark", Pos:="Top", TimeOut)
    CustomGUI.PopUp(Text, Title, SubTitle, Theme := "Dark", Pos := "x682 y403", TimeOut)


    info := CustomGUI.Info("xxx", , 0)


    return

    ; Sleep 2000

    ; MsgBox()


    ; INIT:


    CustomGUI.PopUp(, "LTop", , Theme := "Light", Pos := "LTop", TimeOut := 500)
    CustomGUI.PopUp(, "Top", , Theme := "Dark", Pos := "Top", TimeOut := 1000)
    CustomGUI.PopUp(, "RTop", , Theme := "Light", Pos := "RTop", TimeOut := 1500)

    CustomGUI.PopUp(, "LCenter", , Theme := "Dark", Pos := "LCenter", TimeOut := 2000)
    CustomGUI.PopUp(, "Center", , Theme := "Light", Pos := "Center", TimeOut := 2500)
    CustomGUI.PopUp(, "RCenter", , Theme := "Dark", Pos := "RCenter", TimeOut := 3000)

    CustomGUI.PopUp(, "LBelow", , Theme := "Light", Pos := "LBelow", TimeOut := 3500)
    CustomGUI.PopUp(, "Below", , Theme := "Dark", Pos := "Below", TimeOut := 4000)
    CustomGUI.PopUp(, "RBelow", , Theme := "Light", Pos := "RBelow", TimeOut := 4500)

    CustomGUI.PopUp(, "Custom", "xCenter y900", Theme := "Light", Pos := "xCenter y900", 5500)
    CustomGUI.PopUp("PopUp", "Custom", "xCenter y200", Theme := "Dark", Pos := "xCenter y200", 6000)

    Sleep 2000

    CustomGUI.Set_Info("Text", , 1500)
    CustomGUI.Set_Info("Text", , 1000)
    Sleep 2000
    CustomGUI.Info("Text", , 500)
    CustomGUI.Info("Text", , 1000)

    Sleep 2000

    CustomGUI.Set_Info.FontSize := 15
    CustomGUI.Set_Info.Distance := 2.8
    ; CustomGUI.Set_Info.Distance := 1.95

    info := CustomGUI.Set_Info("Text", , 1000)
    info := CustomGUI.Set_Info("Text", , 500)
    Sleep 500
    info.ReplaceText("New Text")

    Sleep 1500

    info2 := CustomGUI.Info("Text", , 1000)
    info2 := CustomGUI.Info("Text", , 500)
    Sleep 500
    info2.ReplaceText("New Text")


    Sleep 1000

    ; INIT:
    CustomGUI.Set_Info.MaxWidthInChars := 104
    CustomGUI.Set_Info.FontSize := 20
    info := CustomGUI.Info("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX0000", , 0)
    Sleep 600
    info.Destroy

    CustomGUI.Set_Info.MaxWidthInChars := 100
    info := CustomGUI.Info("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX0000")
    Sleep 600
    info.Destroy

    Sleep 100
    info := CustomGUI.Info("====================================================================================================")
    Sleep 500
    info.ReplaceText("Text")
    Sleep 500
    info.ReplaceText("       ")
    Sleep 500
    info.ReplaceText("")

    Sleep 1000

    ; INIT:

    CustomGUI.Set_Info.FontSize := 15
    CustomGUI.Set_Info.Distance := 2
    NumInfos := 30
    CustomGUI.PopUp("CustomGUI.Set_Info", "FontSize", CustomGUI.Set_Info.FontSize, , , ((((200 * NumInfos) * 100) / 80) * 2) + 1000)
    Sleep 1000

    loop NumInfos {
        Info := Object()
        Info.%A_Index% := CustomGUI.Info("Text: " A_Index, , (((200 * NumInfos) * 100) / 80))
        Sleep 100
        Info.%A_Index%.ReplaceText("                 ")
        Sleep 100
        Info.%A_Index%.ReplaceText("     ")
    }


    Sleep 1000

    ; INIT:

    CustomGUI.Set_Info.FontSize := 30
    CustomGUI.Set_Info.Distance := 3

    NumInfos := 3
    CustomGUI.PopUp("CustomGUI.Set_Info", "FontSize", CustomGUI.Set_Info.FontSize, , , ((((200 * NumInfos) * 100) / 80) * 2) + 1000)
    Sleep 1000

    loop NumInfos {
        Info := Object()
        Info.%A_Index% := CustomGUI.Info("Text: " A_Index, "Light", (((200 * NumInfos) * 100) / 80))
        Sleep 100
        Info.%A_Index%.ReplaceText("                 ")
        Sleep 100
        Info.%A_Index%.ReplaceText("     ")
    }
    Sleep 1000

    goto INIT