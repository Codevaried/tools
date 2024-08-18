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
#include "../../../Lib/Tools/Highlight.ahk"


; ;^ ----------------- GenerateHollowCircleRegion ----------------------

; ;; Ejemplo 1: Generar una región de círculo hueco con radio exterior 100 y radio interior 50
; region1 := GenerateHollowCircleRegion(100, 50)
; MsgBox(region1, "Región de círculo hueco (radio exterior: 100, radio interior: 50)")

; ;; Ejemplo 2: Generar una región de círculo hueco con radio exterior 200 y radio interior 100
; region2 := GenerateHollowCircleRegion(200, 100)
; MsgBox(region2, "Región de círculo hueco (radio exterior: 200, radio interior: 100)")

; ;; Ejemplo 3: Generar una región de círculo hueco con radio exterior 150 y radio interior 75
; region3 := GenerateHollowCircleRegion(150, 75)
; MsgBox(region3, "Región de círculo hueco (radio exterior: 150, radio interior: 75)")

; ;; Ejemplo 4: Generar una región de círculo hueco con radio exterior 250 y radio interior 125
; region4 := GenerateHollowCircleRegion(250, 125)
; MsgBox(region4, "Región de círculo hueco (radio exterior: 250, radio interior: 125)")

; ;; Ejemplo 5: Generar una región de círculo hueco con radio exterior 50 y radio interior 25
; region5 := GenerateHollowCircleRegion(50, 25)
; MsgBox(region5, "Región de círculo hueco (radio exterior: 50, radio interior: 25)")


;^ ----------------- Highlight ----------------------

;; Ejemplo 1: Resaltar un área rectangular con un borde rojo durante 2 segundos
Highlight(100, 100, 200, 200)

;; Ejemplo 2: Resaltar un área rectangular con un borde azul durante 5 segundos
Highlight(300, 300, 150, 150, 5000, "Blue")

;; Ejemplo 3: Resaltar un área rectangular indefinidamente
Highlight(500, 500, 100, 100, 0, "Green")

;; Ejemplo 4: Eliminar todos los resaltados existentes
Sleep(3000) ;; Esperamos 3 segundos antes de limpiar
Highlight()

;; Ejemplo 5: Resaltar un área circular con un borde rojo durante 2 segundos
Highlight(700, 100, 100, 100, 2000, "Red", 2, 1)

;; Ejemplo 6: Resaltar un área circular con un borde azul durante 5 segundos
Highlight(900, 300, 150, 150, 5000, "Blue", 2, 1)

;; Ejemplo 7: Resaltar un área circular indefinidamente
Highlight(1100, 500, 100, 100, 0, "Green", 2, 1)

;; Ejemplo 8: Eliminar todos los resaltados existentes
Sleep(3000) ;; Esperamos 3 segundos antes de limpiar
Highlight()


;^ ----------------- MouseTip ----------------------

;; Ejemplo 1: Resaltar la posición actual del cursor como rectángulo
MouseTip(, , , , , 0)

;; Ejemplo 2: Resaltar la posición actual del cursor como círculo
MouseTip(, , , , , 1)

;; Ejemplo 3: Resaltar la posición actual del cursor
MouseTip()

;; Ejemplo 4: Resaltar una posición específica en la pantalla
MouseTip(400, 400)

;; Ejemplo 5: Usar colores personalizados para el resaltado
MouseTip(500, 500, "yellow", "purple")

;; Ejemplo 6: Usar un rectángulo para resaltar una posición específica
MouseTip(600, 600, "green", "c60e7f", 2, 0)

;; Ejemplo 7: Usar un círculo para resaltar una posición específica
MouseTip(700, 700, "blue", "red", 3, 1)


;^ ----------------- FollowMouse ----------------------

;; Ejemplo 1: Seguir el puntero del mouse con un círculo rojo
FollowMouse()
Sleep(3000) ;; Esperamos 3 segundos antes de limpiar
FollowMouse()

;; Ejemplo 2: Seguir el puntero del mouse con un círculo azul y borde de 4 píxeles
FollowMouse("Blue", 4)
Sleep(3000) ;; Esperamos 3 segundos antes de limpiar
FollowMouse()

;; Ejemplo 3: Seguir el puntero del mouse con un círculo verde de tamaño 40 y borde de 3 píxeles
FollowMouse("Green", 3, 40)
Sleep(3000) ;; Esperamos 3 segundos antes de limpiar
FollowMouse()

;; Ejemplo 4: Seguir el puntero del mouse con un rectángulo rojo de tamaño 50
FollowMouse("Red", 2, 50, 5, 0)
Sleep(3000) ;; Esperamos 3 segundos antes de limpiar
FollowMouse()