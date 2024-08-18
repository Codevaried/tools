#Requires AutoHotkey v2.0
#SingleInstance Force

#Requires AutoHotkey v2.0.0+
#SingleInstance Force

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

;; Incluir otras librerías necesarias
#include "../Lib/Misc/Misc.ahk"


;^ ----------------- Print ----------------------

;; Ejemplo 1: Imprimir un Mensaje Simple
Print("Hello")

;; Ejemplo 2: Imprimir un Número
Print(123)

;; Ejemplo 3: Imprimir una Cadena de Texto
Print("Hola, mundo!")

;; Ejemplo 4: Imprimir un Array
arr := [1, 2, 3, 4, 5]
Print(arr)

;; Ejemplo 5: Usar un Carácter de Nueva Línea Diferente
Print("Este es un mensaje.", MsgBox, "`r`n")

;; Ejemplo 6: Imprimir la Función y el Carácter de Nueva Línea Actuales
result := Print()
MsgBox("Función de impresión actual: " ToString(result[1]) "`nCarácter de nueva línea actual: " result[2])

;; Ejemplo 7: Imprimir un Valor sin Función de Impresión (Retorno como Cadena)
result := Print("Solo retorno como cadena", "")
MsgBox(result)

;; Ejemplo 8: Imprimir con Función MsgBox
Print(, MsgBox)
Print("Mostrar MsgBox")


;^ ----------------- ToString ----------------------

;; Ejemplo 1: Convertir un Número a Cadena
MsgBox(ToString(123)) ;; Salida: 123

;; Ejemplo 2: Convertir una Cadena a Cadena
MsgBox(ToString("Hola")) ;; Salida: 'Hola'

;; Ejemplo 3: Convertir un Array a Cadena
arr := [1, 2, 3]
MsgBox(ToString(arr)) ;; Salida: [1, 2, 3]

;; Ejemplo 4: Convertir un Objeto a Cadena
obj := { name: "AutoHotkey", version: 2 }
MsgBox(ToString(obj)) ;; Salida: {name: 'AutoHotkey', version: 2}


;^ ----------------- Range ----------------------

;; Bucle hacia adelante, equivalente al Bucle 10
result := ""
for v in Range(10)
    result .= v "`n"
Print(result)

;; Bucle hacia atrás, equivalente a Range(1,10,-1)
Print(Range(10, 1).ToArray())

;; Bucle hacia adelante, paso 2
Print(Range(-10, 10, 2).ToArray())

;; Bucle anidado
result := ""
for v in Range(3)
    for k in Range(5, 1)
        result .= v " " k "`n"
Print(result)


;^ ----------------- RegExMatchAll ----------------------

result := ""
matches := RegExMatchAll("a,bb,ccc", "\w+")

Print(matches, MsgBox)

for i, match in matches
    result .= "Match " i ": " match[] "`n"
Print(result)


;^ ----------------- Swap ----------------------

;; Ejemplo 1: Intercambiar dos números
a := 5
b := 10
Swap(&a, &b)
MsgBox("a: " a ", b: " b) ;; Salida: a: 10, b: 5

;; Ejemplo 2: Intercambiar dos cadenas
str1 := "Hola"
str2 := "Mundo"
Swap(&str1, &str2)
MsgBox("str1: " str1 ", str2: " str2) ;; Salida: str1: Mundo, str2: Hola


;^ ----------------- WindowFromPoint ----------------------

;; Ejemplo 1: Obtener el ID de la ventana en una posición específica
x := 200
y := 300
windowID := WindowFromPoint(x, y)
MsgBox("Window ID: " windowID)


;^ ----------------- ConvertWinPos ----------------------

;; Ejemplo 1: Convertir coordenadas de pantalla a coordenadas de cliente
screenX := 500
screenY := 400
ConvertWinPos(screenX, screenY, &clientX, &clientY, "screen", "client")
MsgBox("Cliente X: " clientX ", Cliente Y: " clientY)

;; Ejemplo 2: Convertir coordenadas de cliente a coordenadas de pantalla
clientX := 100
clientY := 150
ConvertWinPos(clientX, clientY, &screenX, &screenY, "client", "screen")
MsgBox("Pantalla X: " screenX ", Pantalla Y: " screenY)


;^ ----------------- WinGetInfo ----------------------

;; Ejemplo 1: Obtener información detallada de la ventana activa
info := WinGetInfo("A", 1)
MsgBox(info)

;; Ejemplo 2: Obtener información básica de una ventana específica
try {
    info := WinGetInfo("ahk_exe notepad.exe", 0)
    MsgBox(info)
} catch Any as e {
    MsgBox("Error: " e.message)
}


;^ ----------------- GetCaretPos ----------------------

;; Ejemplo 1: Obtener la posición del cursor de texto
GetCaretPos(&caretX, &caretY)
MsgBox("Caret X: " caretX ", Caret Y: " caretY)


;^ ----------------- IntersectRect ----------------------

;; Ejemplo 1: Verificar la intersección de dos rectángulos
rect1 := { l: 100, t: 100, r: 200, b: 200 }
rect2 := { l: 150, t: 150, r: 250, b: 250 }
intersection := IntersectRect(rect1.l, rect1.t, rect1.r, rect1.b, rect2.l, rect2.t, rect2.r, rect2.b)
if intersection
    MsgBox("Intersección: " ToString(intersection))
else
    MsgBox("No hay intersección")