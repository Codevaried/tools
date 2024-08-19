#include "../Lib/Tools/Timer.ahk"

class TimerTestSuite {

    ;; Test 1: Iniciar el temporizador y verificar el tiempo transcurrido
    Test_StartStop() {
        t := Timer()
        t.Start()
        Sleep(1000) ;; Esperar 1 segundo
        t.Stop()
        DUnit.Equal(t.ElapsedTime, 1000, "El tiempo transcurrido debe ser de aproximadamente 1000 ms.")
    }

    ;; Test 2: Reanudar el temporizador y verificar el tiempo acumulado
    Test_Resume() {
        t := Timer()
        t.Start()
        Sleep(1000) ;; Esperar 1 segundo
        t.Stop()
        DUnit.Equal(t.ElapsedTime, 1000, "El tiempo transcurrido debe ser de aproximadamente 1000 ms.")
        t.Resume()
        Sleep(500) ;; Esperar 0.5 segundos adicionales
        t.Stop()
        DUnit.Equal(t.ElapsedTime, 1500, "El tiempo transcurrido debe ser de aproximadamente 1500 ms.")
    }

    ;; Test 3: Reiniciar el temporizador y verificar que el tiempo es 0
    Test_Reset() {
        t := Timer()
        t.Start()
        Sleep(1000) ;; Esperar 1 segundo
        t.Stop()
        t.Reset()
        DUnit.Equal(t.ElapsedTime, 0, "El tiempo transcurrido debe ser 0 después del reinicio.")
    }

    ;; Test 4: Verificar si el temporizador está corriendo
    Test_IsRunning() {
        t := Timer()
        t.Start()
        DUnit.True(t.IsRunning, "El temporizador debería estar funcionando")
        t.Stop()
        DUnit.False(t.IsRunning, "El temporizador no debería estar funcionando después de detenerse")
    }

    ;; Test 5: Iniciar el temporizador después de reiniciarlo
    Test_StartAfterReset() {
        t := Timer()
        t.Reset()
        t.Start()
        Sleep(700) ;; Esperar 0.7 segundos
        t.Stop()
        DUnit.Range(t.ElapsedTime, 690, 710, "El tiempo transcurrido debe ser de aproximadamente 700 ms después del reinicio.")
    }

    ;; Test 6: Verificación del tiempo transcurrido en múltiples etapas
    Test_MultipleStages() {
        t := Timer()

        ;; Etapa 1: Iniciar y comprobar el tiempo
        t.Start()
        DUnit.True(t.ElapsedTime >= 0, "El tiempo transcurrido debería ser al menos 0 ms")
        Sleep(500) ;; Esperar 0.5 segundos
        DUnit.True(t.ElapsedTime >= 500, "El tiempo transcurrido debería ser al menos 500 ms")

        ;; Etapa 2: Reiniciar y comprobar nuevamente
        t.Reset()  ;; Reinicia y detiene el temporizador
        DUnit.Equal(t.ElapsedTime, 0, "El tiempo transcurrido debería ser 0 después del reinicio")
        t.Start()  ;; Inicia nuevamente después del reinicio
        Sleep(300) ;; Esperar 0.3 segundos
        DUnit.Range(t.ElapsedTime, 295, 305, "El tiempo transcurrido debería ser de aproximadamente 300 ms después de reiniciar.")

        ;; Etapa 3: Limpiar el temporizador y comprobar nuevamente
        t.Clear()  ;; Reinicia el tiempo transcurrido pero mantiene el temporizador corriendo
        DUnit.Equal(t.ElapsedTime, 0, "El tiempo transcurrido debería ser 0 después de Clear")
        Sleep(200) ;; Esperar 0.2 segundos
        DUnit.True(t.ElapsedTime >= 200, "El tiempo transcurrido debería ser al menos 200 ms después de Clear")

        ;; Detener el temporizador
        t.Stop()
    }

    ;; Test 7: Clear el temporizador sin detenerlo
    Test_Clear() {
        t := Timer()
        t.Start()
        Sleep(1000) ;; Esperar 1 segundo
        t.Clear()   ;; Reinicia el tiempo transcurrido pero sigue corriendo
        DUnit.Equal(t.ElapsedTime, 0, "El tiempo transcurrido debería ser 0 justo después de Clear")
        Sleep(500)  ;; Esperar 0.5 segundos
        DUnit.Equal(t.ElapsedTime, 500, "El tiempo transcurrido debe ser de aproximadamente 500 ms después de Clear.")
    }

    /**
     * Método `End` que se ejecuta al finalizar todas las pruebas en la clase.
     * En este ejemplo, se utiliza para medir el tiempo transcurrido utilizando un temporizador
     * y mostrar los resultados en diferentes unidades de tiempo.
     */
    End() {
        ;; Crear una instancia de la clase Timer
        t := Timer()

        ;; Iniciar el temporizador
        t.Start()

        ;; Esperar 1000 milisegundos (1 segundo)
        Sleep(1000)

        ;; Detener el temporizador
        t.Stop()

        ;; Construir el mensaje con los diferentes tiempos transcurridos
        msg := "Tiempo transcurrido:`n`n"
        msg .= "Milisegundos (con decimales): " t.ElapsedTime["ms"] " ms`n"
        msg .= "Segundos (con decimales): " t.ElapsedTime["s"] " s`n"
        msg .= "Minutos (con decimales): " t.ElapsedTime["m"] " m`n"
        msg .= "Horas (con decimales): " t.ElapsedTime["h"] " h`n`n"
        msg .= "Milisegundos (redondeado): " t.GetElapsedTimeRounded("ms") " ms`n"
        msg .= "Segundos (redondeado): " t.GetElapsedTimeRounded("s") " s`n"
        msg .= "Minutos (redondeado): " t.GetElapsedTimeRounded("m") " m`n"
        msg .= "Horas (redondeado): " t.GetElapsedTimeRounded("h") " h"

        ;; Mostrar el mensaje
        MsgBox(msg)
        ; OutputDebug("_________________________`n" msg "`n_________________________")
    }
}