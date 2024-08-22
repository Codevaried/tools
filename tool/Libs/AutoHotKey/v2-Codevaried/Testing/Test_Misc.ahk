#include "../Lib/Misc/Misc.ahk"

class MiscTestSuite {

    InitTest() {
        Print("`n", "")
    }


    Test_PrintExample() {
        ;; Ejemplo 1: Imprimir un valor con un título personalizado.
        Print("Este es un mensaje", "Título Personalizado")

        ;; Ejemplo 2: Cambiar la función de salida a MsgBox.
        Print("Este es un mensaje", "Aviso", MsgBox)

        ;; Ejemplo 3: Imprimir un objeto con ToString().
        obj := { ToString: () => "Descripción del objeto" }
        Print(obj)
    }

    Test_Print() {
        DUnit.Equal(Print("`n"), "`n")
        DUnit.Equal(Print(""), "")
        DUnit.Equal(Print("", ""), "")
        DUnit.Equal(Print("", "null"), "")

        DUnit.Equal(Print("a"), "a")
        DUnit.Equal(Print("a", ""), "a")
        DUnit.Equal(Print("a", "null"), "a")

        DUnit.Equal(Print([]), "[]")
        DUnit.Equal(Print(Map()), "Map()")
        DUnit.Equal(Print({}), "{}")
        DUnit.Equal(Print([1]), "[1]")
        DUnit.Equal(Print(Map("key", "value")), "Map('key':'value')")
        DUnit.Equal(Print({ key: "value" }), "{key:'value'}")
        DUnit.Equal(Print([1, [2, [3, 4]]]), "[1, [2, [3, 4]]]")
        DUnit.Equal(Print(Map(1, 2, "3", "4")), "Map(1:2, '3':'4')")
        DUnit.Equal(Print({ key: "value", 1: 2, 3: "4" }), "{1:2, 3:'4', key:'value'}")
    }

    Test_Swap() {
        a := 1, b := 2
        Swap(&a, &b)
        DUnit.Equal(a, 2)
        DUnit.Equal(b, 1)
    }

    Test_Range() {
        DUnit.Equal(Print(Range(5)), "Range(1:1, 2:2, 3:3, 4:4, 5:5)")
        DUnit.Equal(Range(5).ToArray(), [1, 2, 3, 4, 5])
        DUnit.Equal(Print(Range(0)), "Range(1:1, 2:0)")
    }

    Test_Range2() { ; Split into two because of the ListLines limitation
        DUnit.Equal(Print(Range(3, 5)), "Range(1:3, 2:4, 3:5)")
        DUnit.Equal(Print(Range(5, 3)), "Range(1:5, 2:4, 3:3)")
        DUnit.Equal(Print(Range(5, , 2)), "Range(1:1, 2:3, 3:5)")
        DUnit.Equal(Print(Range(5, -5, -2)), "Range(1:5, 2:3, 3:1, 4:-1, 5:-3, 6:-5)")
    }

    Test_RegExMatchAll() {
        DUnit.Equal(RegExMatchAll("", "\w+"), [])
        DUnit.Equal(Print(RegExMatchAll("a,bb,ccc", "\w+")), "[RegExMatchInfo(0:'a'), RegExMatchInfo(0:'bb'), RegExMatchInfo(0:'ccc')]")
        DUnit.Equal(Print(RegExMatchAll("a,bb,ccc", "\w+", 4)), "[RegExMatchInfo(0:'b'), RegExMatchInfo(0:'ccc')]")
    }

    Test_ConvertWinPos() {
        ;; Guarda el modo de coordenadas del ratón actual para restaurarlo después de la prueba.
        ccm := A_CoordModeMouse
        Print(A_CoordModeMouse)

        ;; Asegura que la ventana activa sea la que estamos usando para las conversiones.
        WinExist("A")

        ;; Cambia el modo de coordenadas del ratón a 'client' para obtener las coordenadas relativas al cliente.
        A_CoordModeMouse := "client"
        Print(A_CoordModeMouse)

        ;; Mueve el ratón a las coordenadas (100, 200) dentro del área cliente de la ventana activa.
        MouseMove(100, 200)

        ;; Obtiene las coordenadas actuales del ratón en modo 'client' y las almacena en `clientX` y `clientY`.
        MouseGetPos(&clientX, &clientY)
        Print(clientX " " clientY)

        ;; Cambia el modo de coordenadas del ratón a 'screen' para obtener las coordenadas relativas a la pantalla.
        A_CoordModeMouse := "screen"
        Print(A_CoordModeMouse)

        ;; Obtiene las coordenadas actuales del ratón en modo 'screen' y las almacena en `screenX` y `screenY`.
        MouseGetPos(&screenX, &screenY)
        Print(screenX " " screenY)

        ;; Cambia el modo de coordenadas del ratón a 'window' para obtener las coordenadas relativas a la ventana.
        A_CoordModeMouse := "window"
        Print(A_CoordModeMouse)

        ;; Obtiene las coordenadas actuales del ratón en modo 'window' y las almacena en `windowX` y `windowY`.
        MouseGetPos(&windowX, &windowY)
        Print(windowX " " windowY)

        ;; Restaura el modo de coordenadas del ratón al valor original antes de la prueba.
        A_CoordModeMouse := ccm
        Print(A_CoordModeMouse)

        ;; Convierte las coordenadas de 'screen' a 'client' y verifica que coincidan con las coordenadas obtenidas previamente en modo 'client'.
        ConvertWinPos(screenX, screenY, &OutX, &OutY, "screen", "client", "A")
        DUnit.Equal(clientX " " clientY, OutX " " OutY)

        ;; Convierte las coordenadas de 'client' a 'screen' y verifica que coincidan con las coordenadas obtenidas previamente en modo 'screen'.
        ConvertWinPos(clientX, clientY, &OutX, &OutY, "client", "screen", "A")
        DUnit.Equal(screenX " " screenY, OutX " " OutY)

        ;; Convierte las coordenadas de 'window' a 'screen' y verifica que coincidan con las coordenadas obtenidas previamente en modo 'screen'.
        ConvertWinPos(windowX, windowY, &OutX, &OutY, "window", "screen", "A")
        DUnit.Equal(screenX " " screenY, OutX " " OutY)

        ;; Convierte las coordenadas de 'screen' a 'window' y verifica que coincidan con las coordenadas obtenidas previamente en modo 'window'.
        ConvertWinPos(screenX, screenY, &OutX, &OutY, "screen", "window", "A")
        DUnit.Equal(windowX " " windowY, OutX " " OutY)

        ;; Convierte las coordenadas de 'client' a 'window' y verifica que coincidan con las coordenadas obtenidas previamente en modo 'window'.
        ConvertWinPos(clientX, clientY, &OutX, &OutY, "client", "window", "A")
        DUnit.Equal(windowX " " windowY, OutX " " OutY)

        ;; Convierte las coordenadas de 'window' a 'client' y verifica que coincidan con las coordenadas obtenidas previamente en modo 'client'.
        ConvertWinPos(windowX, windowY, &OutX, &OutY, "window", "client", "A")
        DUnit.Equal(clientX " " clientY, OutX " " OutY)
    }
}