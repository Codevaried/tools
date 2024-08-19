#Requires AutoHotkey v2.0.0+
#SingleInstance Force

/**
 * @file GravityDropTimer (Temporizador y cálculo de altura/velocidad terminal en caída libre)
 * @version 0.1 (18.08.24)
 * @created 18.08.24
 * @author Codevaried
 * @description
 * Este script inicia y detiene un temporizador al presionar una tecla o botón.
 * Además, calcula la altura teórica en metros y la velocidad de impacto con el agua (velocidad terminal)
 * basada en el tiempo transcurrido utilizando las leyes de la física.
 * 
 * @note Este cálculo asume un modelo ideal de caída libre sin resistencia del aire, 
 *       lo cual es válido para estimaciones en alturas moderadas como 5-25 ~ metros.
 */

;;MARK:*
;^----------------Configuración Inicial----------------^;

;; Incluir la clase Timer desde un archivo externo
#Include "../../../Libs/AutoHotKey/v2-Codevaried/Lib/Tools/Timer.ahk"

;; Establece la prioridad del proceso en muy alta utilizando una función nativa de AutoHotkey
ProcessSetPriority("High")

;! Modo desarrollo: Hotkeys para recargar el script y salida rápida
#HotIf !A_IsCompiled and WinActive("ahk_exe Code.exe")
~^s:: Reload()   ;; Guarda y recarga el script
#HotIf

#HotIf !A_IsCompiled
^Esc:: ExitApp() ;; Salida de seguridad del script
#HotIf

;;MARK:*
;^----------------Definición de Hotkeys----------------^;

;*** Define la tecla o botón para iniciar/detener el temporizador
key := "~Space"
; key := "~^LButton"
; key := "~LButton"
; key := "F12"
Hotkey(key, toggleTimer, "P10")  ;; Asigna la hotkey con alta prioridad

;;MARK:*
;^----------------Variables Globales----------------^;

;; Instancia global del temporizador usando la clase Timer
global t := Timer()

;;MARK:*
;^----------------Funciones----------------^;

/**
 * Emite un sonido de beep basado en la condición proporcionada.
 * @param {Boolean} isActive - Si es true, emite un sonido de tono alto. Si es false, emite un sonido de tono bajo.
 * @param {Integer} [p] - Prioridad opcional para el temporizador del beep.
 */
ModSoundBeep(isActive, p?) => SetTimer(() => SoundBeep(isActive ? 500 : 300, 200), -1, p?)

/**
 * Función que inicia o detiene el temporizador, calcula la altura y la velocidad de impacto.
 * @param {String} [ThisHotkey] - Nombre de la hotkey (no se utiliza, pero es necesario para compatibilidad con Hotkey).
 * 
 * @note Si la línea `ModSoundBeep(true)` está activada, habrá un retraso de unos milisegundos
 *       (en torno a 17ms en algunos sistemas) antes de poder volver a ejecutar esta función.
 *       Este retraso puede variar dependiendo de la velocidad del hardware y del sistema operativo.
 */
toggleTimer(ThisHotkey) {
    global t

    if (t.IsRunning) {
        t.Stop()
        ModSoundBeep(false, 10)

        ;; Convertir tiempo a segundos y calcular la altura teórica
        seconds := t.ElapsedTime / 1000
        g := 9.81  ;; Aceleración debida a la gravedad en m/s^2
        height := 0.5 * g * (seconds ** 2)
        height_rounded := Round(height, 2)  ;; Redondea a 2 decimales

        ;; Comprobar si el tiempo supera los 4 segundos
        if (seconds > 4) {
            MsgBox(
                "Tiempo transcurrido: " . Round(seconds, 2) . " segundos.`n" .
                "Altura calculada: " . height_rounded . " metros.`n`n" .
                "Nota: Tiempo demasiado largo para un salto al agua, se omite el cálculo de la velocidad terminal.",
                "Resultado del Temporizador"
            )
        } else {
            ;; Calcular la velocidad terminal (en ausencia de resistencia del aire)
            velocity := g * seconds
            velocity_rounded := Round(velocity, 2)  ;; Redondea a 2 decimales

            ;; Mostrar toda la información en un MsgBox visual
            MsgBox(
                "Tiempo transcurrido: " . Round(seconds, 2) . " segundos.`n" .
                "Altura calculada: " . height_rounded . " metros.`n" .
                "Velocidad de impacto (simplificada): " . velocity_rounded . " m/s`n`n" .
                "Nota: Este cálculo asume un modelo ideal sin resistencia del aire, adecuado para estimaciones de alturas moderadas.",
                "Resultado del Temporizador"
            )
        }
    } else {
        t.Reset()  ;; Reinicia el temporizador a cero antes de iniciarlo nuevamente
        t.Start()
        ModSoundBeep(true) ;;! Si esta línea está activada habrá un delay de unos milisegundos antes de poder volver a ejecutar esta función
    }
}