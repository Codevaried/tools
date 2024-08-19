#Include "../Misc/Misc.ahk"

/**
 * @file DUnit.ahk
 * ! @version 0.2 (19.08.24) (*MOD*) 
 * @created 18.08.24
 * @author Codevaried
 * @description
 * Esta biblioteca simplificada proporciona funciones para realizar pruebas unitarias en AHK v2.
 * 
 * Funciones incluidas:
 * - DUnit.Assert: Verifica una condición y lanza un error si es falsa.
 * - DUnit.True: Verifica si la condición dada no es falsa.
 * - DUnit.False: Verifica si la condición dada es falsa.
 * - DUnit.Equal: Verifica si dos condiciones o valores son iguales.
 * - DUnit.NotEqual: Verifica si dos condiciones o valores no son iguales.
 * - DUnit.Throws: Verifica si una función lanza un error y opcionalmente verifica el tipo de error.
 * - DUnit.RunTests: Ejecuta todos los métodos de prueba en clases dadas que comienzan con "Test_".
 * 
 * @credit
 * * Descolada - Autor original de la librería en la que se basa esta versión simplificada.
 * 
 * @note
 * * Esta es una versión modificada y simplificada de la librería original DUnit. La versión original se puede encontrar en el repositorio oficial de Descolada.
 */


class DUnit {
    static methodCount := 0  ;; Contador de métodos ejecutados por cada prueba.

    /**
     * Verifica si la condición es verdadera. Si no lo es, lanza un error con el mensaje especificado.
     * @param condition Condición a verificar.
     * @param msg Mensaje de error si la condición es falsa.
     * @param n Posición del argumento en el error, por defecto es -1.
     */
    static Assert(condition, msg := "Fail", n := -1) {
        if !condition
            throw Error(msg, n, "!")
    }

    /**
     * Verifica si la condición a es verdadera.
     * @param a Condición a verificar.
     * @param msg Mensaje de error si la condición es falsa.
     */
    static True(a, msg := "Not True") => DUnit.Assert(a, msg, -2)

    /**
     * Verifica si la condición a es falsa.
     * @param a Condición a verificar.
     * @param msg Mensaje de error si la condición es verdadera.
     */
    static False(a, msg := "Not False") => DUnit.Assert(!a, msg, -2)

    /**
     * Verifica si dos valores son iguales.
     * @param a Primer valor.
     * @param b Segundo valor.
     * @param msg Mensaje de error si los valores no son iguales.
     * @param n Posición del argumento en el error, por defecto es -1.
     */
    static Equal(a, b, msg := "Not Equal", n := -1) {
        DUnit.methodCount++
        if (a != b)
            throw Error(msg, n, "(" a ") != (" b ")")
    }

    /**
     * Verifica si dos valores no son iguales.
     * @param a Primer valor.
     * @param b Segundo valor.
     * @param msg Mensaje de error si los valores son iguales.
     * @param n Posición del argumento en el error, por defecto es -1.
     */
    static NotEqual(a, b, msg := "Are Equal", n := -1) {
        DUnit.methodCount++
        if (a == b)
            throw Error(msg, n, "(" a ") == (" b ")")
    }

    /**
     * Verifica si una función lanza un error. Opcionalmente, verifica el tipo de error.
     * @param func Función a probar.
     * @param errorType Tipo de error esperado (opcional).
     * @param msg Mensaje de error si no se lanza un error o si el tipo de error es incorrecto.
     */
    static Throws(func, errorType := "", msg := "FAIL (didn't throw)") {
        DUnit.methodCount++
        try {
            func()
        } catch as e {
            if IsSet(errorType) && (Type(e) != errorType)
                throw Error(msg, "(incorrect error type)")
            return
        }
        throw Error(msg, "(didn't throw)")
    }

    /**
     * Ejecuta todas las pruebas en las clases proporcionadas.
     * Cada clase se instancia y se ejecutan todos los métodos que comienzan con 'Test_'.
     * Los resultados de las pruebas se imprimen, incluyendo los éxitos y fallos.
     * @param testClasses Clases que contienen los métodos de prueba.
     */
    static RunTests(testClasses*) {
        totalFails := 0, totalSuccesses := 0, startTime := A_TickCount

        ;; Imprime la línea de separación inicial
        Print("", , , "")
        Print("========================", , , "")

        for testClass in testClasses {
            if !IsObject(testClass) {
                continue
            }

            instance := testClass()
            className := Type(instance)
            Print("============", , , "")
            Print("Iniciando pruebas en la clase: " className, , , "*")

            classFails := 0, classSuccesses := 0  ;; Contadores para éxitos y fallos por clase

            for test in ObjOwnProps(testClass.Prototype) {
                if (SubStr(test, 1, 5) = "Test_") { ;; Ejecuta solo los métodos que comienzan con 'Test_'
                    DUnit.methodCount := 0 ;; Resetear el contador para cada método de prueba
                    methodName := test
                    fails := 0, successes := 0

                    try {
                        instance.%test%()
                        successes++
                        Print(methodName, , , "Success")
                    } catch as e {
                        fails++
                        Print(methodName ":" DUnit.methodCount ":`n - " StrReplace(e.File, A_InitialWorkingDir "\") ":line:" e.Line " -> " e.Extra "`n - " e.Message, , , "Fail")
                    }

                    classFails += fails
                    classSuccesses += successes
                }
            }

            ;; Imprime los resultados por clase
            Print("Resultados para la clase " className ": " classSuccesses " successes, " classFails " errors.", , , "*")
            totalFails += classFails
            totalSuccesses += classSuccesses
        }

        ;; Imprime los resultados totales
        totalTests := totalFails + totalSuccesses
        elapsedTime := Round((A_TickCount - startTime) / 1000, 3)
        Print("============", , , "")
        Print("========================", , , "")
        Print("Total de " totalTests " tests en " elapsedTime "s: " totalSuccesses " successes, " totalFails " errors.", , , "#")
    }
}