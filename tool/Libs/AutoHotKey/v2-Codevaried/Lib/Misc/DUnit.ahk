#Include "../Misc/Misc.ahk" ;; Solo para la funcion `Print`

/**
 * @file DUnit.ahk
 * @version 0.8 (24.08.24)
 * @created 18.08.24
 * @author Codevaried
 * @description
 * Esta biblioteca proporciona un marco para realizar pruebas unitarias en AutoHotkey v2.
 * 
 * ==Funciones Principales==
 * - DUnit.Assert: Verifica una condición y lanza un error si es falsa.
 * - DUnit.True: Verifica si la condición dada es verdadera.
 * - DUnit.False: Verifica si la condición dada es falsa.
 * - DUnit.Equal: Verifica si dos valores son iguales.
 * - DUnit.NotEqual: Verifica si dos valores no son iguales.
 * - DUnit.Range: Verifica si un valor está dentro de un rango dado.
 * - DUnit.Throws: Verifica si una función lanza un error y opcionalmente verifica el tipo de error.
 *   Si la función es un método de instancia, se debe vincular a `this` y a los parámetros usando `Bind`.
 * 
 * ==Funciones de Configuración==
 * - DUnit.SetOptions: Configura las opciones de prueba (`Verbose` y `FailFast`).
 *   Permite establecer o alternar entre diferentes opciones utilizando prefijos específicos.
 * - DUnit.RunTests: Ejecuta todos los métodos de prueba en clases dadas que comienzan con "Test_".
 *   También maneja métodos opcionales como `Init` y `End` para inicialización y limpieza.
 *   Se pueden configurar opciones como `Verbose` para detalles adicionales y `FailFast` para detenerse en la primera falla.
 * 
 * ==Detalles Adicionales==
 * @credit
 * * Descolada - Autor original de la librería en la que se basa esta versión modificada.
 * 
 * @note
 * * Esta es una versión mejorada y personalizada de la librería original DUnit.
 *   La versión original se puede encontrar en el repositorio oficial de Descolada.
 */


class DUnit {

    /**
     * Contador estático que rastrea la cantidad de métodos ejecutados en cada prueba.
     * 
     * @type {number}
     * @private
     */
    static _methodCount := 0


    /**
     * Configuración estática para controlar el comportamiento del sistema de pruebas.
     * 
     * @type {Object}
     * @property {boolean} Verbose - Indica si se deben imprimir mensajes detallados para cada prueba exitosa.
     * @property {boolean} FailFast - Indica si el sistema debe detenerse después de la primera falla en las pruebas.
     * @private
     */
    static _config := { Verbose: unset, FailFast: unset }


    ;todo---MARK: Config&Use


    ;
    ;
    ;


    ;;MARK:*
    ;^----------------SetOptions----------------^;

    /**
     * Aplica opciones de DUnit.
     * 
     * Esta función permite configurar las opciones de prueba, como `Verbose` y `FailFast`, 
     * utilizando prefijos específicos (+ para true, - para false) o alternando el estado si no se proporciona prefijo.
     * 
     * @param {string} [options] - Opciones de configuración separadas por espacios. 
     * Se pueden usar los prefijos `+` o `-` para establecer el valor a `true` o `false`, respectivamente. 
     * Si no se proporciona un prefijo, la opción alternará entre `true` y `false` según su estado actual.
     * 
     * @throws {TypeError|ValueError} Si `options` no es una cadena o contiene valores no válidos.
     * 
     * @example
     * DUnit.SetOptions("-F")  ; Establece FailFast en false
     * DUnit.SetOptions("+F")  ; Establece FailFast en true
     * DUnit.SetOptions("F")   ; Alterna el estado actual de FailFast
     * DUnit.SetOptions("-F V")  ; Establece FailFast en false y alterna el estado de Verbose
     * DUnit.SetOptions("Verbose -FailFast")  ;  Alterna el estado de Verbose y establece FailFast en false
     */
    static SetOptions(options?) {
        if IsSet(options) {
            if (Type(options) != "String")
                throw TypeError("Se esperaba una cadena en el parámetro 'options', pero se recibió: " Type(options))

            for option in StrSplit(options, " ") {
                prefijo := SubStr(option, 1, 1)
                valor := SubStr(option, 2)

                Switch prefijo {
                    case "+", "-":
                        Switch valor {
                            case "V", "Verbose":
                                DUnit._config.Verbose := (prefijo = "+")
                            case "F", "FailFast":
                                DUnit._config.FailFast := (prefijo = "+")
                            default:
                                throw ValueError("Opción desconocida: " option)
                        }
                    default:
                        Switch option {
                            case "V", "Verbose":
                                DUnit._config.Verbose := !DUnit._config.Verbose
                            case "F", "FailFast":
                                DUnit._config.FailFast := !DUnit._config.FailFast
                            default:
                                throw ValueError("Opción desconocida: " option)
                        }
                }
            }
        } else {
            DUnit._config := { Verbose: false, FailFast: false }
        }
    }

    /**
     * Constructor estático que inicializa DUnit con las opciones predeterminadas.
     */
    static __New() => DUnit.SetOptions()


    ;;MARK:*
    ;^----------------RunTests----------------^;

    /**
     * Ejecuta todas las pruebas en las clases proporcionadas.
     * 
     * Este método itera a través de un conjunto de clases de prueba, instanciando cada una y ejecutando 
     * todos los métodos que comienzan con 'Test_'. Para cada clase, se ejecutan los métodos `Init` y `End`, 
     * si están definidos, antes y después de las pruebas, respectivamente. También se ejecutan los métodos 
     * `InitTest` y `EndTest` antes y después de cada prueba individual, si están definidos. Los resultados 
     * de las pruebas se imprimen, incluyendo los éxitos y fallos, y se proporciona un resumen final. Además, 
     * se imprime un registro de las opciones activas durante las pruebas (`Verbose` y `FailFast`).
     * 
     * @param {Object} testClasses* - Lista de clases de prueba que contienen los métodos de prueba.
     * 
     * @returns {Object} Un objeto con las siguientes propiedades:
     * - `total` {Number}: El número total de pruebas ejecutadas.
     * - `successes` {Number}: El número de pruebas exitosas.
     * - `errors` {Number}: El número de pruebas fallidas.
     * - `time` {Number}: El tiempo total de ejecución en milisegundos.
     * - `opc` {Object}: Un objeto que indica las opciones activas durante las pruebas (`failFast`, `verbose`).
     * - `classTests` {Object}: Un objeto con un resumen detallado de las clases evaluadas:
     *   - `successes` {Array}: Lista de nombres de las clases que pasaron todas las pruebas.
     *   - `errors` {Array}: Lista de nombres de las clases que tuvieron fallos.
     *   - `notEvaluated` {Array}: Lista de nombres de las clases que no se evaluaron (debido a `failFast`).
     *   - `total` {Array}: Lista completa de todas las clases proporcionadas para la prueba.
     * 
     * @throws {ValueError|TargetError} Si algún argumento proporcionado no es una clase válida o si no se proporcionan clases.
     * 
     * @example
     * class MyTests {
     *     Init() {
     *         ; Configuración antes de las pruebas de la clase
     *     }
     *     InitTest() {
     *         ; Configuración antes de cada prueba individual
     *     }
     *     Test_Example1() {
     *         ; Primera prueba
     *         DUnit.True(1 = 1)
     *     }
     *     Test_Example2() {
     *         ; Segunda prueba
     *         DUnit.False(1 = 2)
     *     }
     *     EndTest() {
     *         ; Limpieza después de cada prueba individual
     *     }
     *     End() {
     *         ; Limpieza después de todas las pruebas de la clase
     *     }
     * }
     * DUnit.RunTests(MyTests)
     */
    static RunTests(testClasses*) {

        ;; Verifica que se hayan pasado clases de prueba
        if (testClasses.Length = 0)
            throw ValueError("Debe proporcionar al menos una clase de prueba a RunTests.", -1)

        for tc in testClasses {
            ;; Verifica que cada argumento sea un objeto (clase válida)
            if !IsObject(tc)
                throw TargetError("Se esperaba una clase válida pero se encontró: " Type(tc), -1)
        }

        failFast := DUnit._config.FailFast
        verbose := DUnit._config.Verbose

        totalFails := 0, totalSuccesses := 0, totalTests := 0, startTime := A_TickCount
        ctSuccesses := [], ctErrors := [], ctNotEvaluated := [], ctTotal := []

        ;; Imprime la línea de separación inicial
        Print("", "")
        Print("========================", "")

        for tc in testClasses
            (IsObject(tc)) && ctTotal.Push(Type(tc()))
        for testClass in testClasses {
            if !IsObject(testClass)
                continue

            instance := testClass()
            className := Type(instance)

            Print("============", "")
            Print("Iniciando pruebas en la clase: " className, "-")

            ;; Llamar al método Init si está definido
            instance.base.HasOwnProp("Init") && instance.Init()

            classFails := 0, classSuccesses := 0  ;; Contadores para éxitos y fallos por clase

            for test in ObjOwnProps(testClass.Prototype) {
                if (SubStr(test, 1, 5) = "Test_") { ;; Cuenta solo los métodos que comienzan con 'Test_'
                    totalTests++
                }
            }

            for test in ObjOwnProps(testClass.Prototype) {
                if (SubStr(test, 1, 5) = "Test_") { ;; Ejecuta solo los métodos que comienzan con 'Test_'
                    DUnit._methodCount := 0 ;; Resetear el contador para cada método de prueba
                    methodName := test

                    ;; Llamar al método InitTest si está definido
                    instance.base.HasOwnProp("InitTest") && instance.InitTest()

                    try {
                        instance.%test%()
                        classSuccesses++
                        if verbose
                            Print(methodName, "Success")
                    } catch as e {
                        classFails++  ;; Incrementa el contador de fallos de la clase
                        SplitPath(e.File, &f)
                        Print(methodName ":" DUnit._methodCount ":`n - " f ":line:" e.Line " -> " e.Extra "`n - " e.Message, "Fail")
                        if failFast
                            break
                    }

                    ;; Llamar al método EndTest si está definido
                    instance.base.HasOwnProp("EndTest") && instance.EndTest()
                }
            }

            ;; Llamar al método End si está definido
            instance.base.HasOwnProp("End") && instance.End()

            ;; Imprime los resultados por clase
            Print("Resultados para la clase " className ": " classSuccesses " successes, " classFails " errors.", "-")

            if classFails > 0
                ctErrors.Push(className)
            else
                ctSuccesses.Push(className)

            totalFails += classFails  ;; Acumula los fallos de la clase en el total
            totalSuccesses += classSuccesses  ;; Acumula los éxitos de la clase en el total

            if failFast && classFails > 0
                break
        }

        ;; Imprime los resultados totales
        elapsedTime := (A_TickCount - startTime)
        elapsedTimeS := Round(elapsedTime / 1000, 3)

        ;; Añade las clases que no fueron evaluadas
        for v in ctTotal {
            if (!ctErrors.IndexOf(v)) && (!ctSuccesses.IndexOf(v)) {
                ctNotEvaluated.Push(v)
            }
        }

        Print("============", "")
        Print("========================", "")
        Print("Total de " totalTests " tests en " elapsedTimeS "s: " totalSuccesses " successes, " totalFails " errors. [ " totalSuccesses "/" totalTests " (" Round(totalSuccesses * 100 / totalTests) "%)" (failFast && totalFails >= 1 ? " Aborted failFast" : "") " ]", "#")

        ;; Imprime las opciones activas durante el test
        Print("Opciones activas: " "Verbose=" (verbose ? "ON" : "OFF") ", " "FailFast=" (failFast ? "ON" : "OFF"), "#")

        ;; Imprime el resumen
        if totalFails == totalTests {
            Print("Resumen: Todas las pruebas fallaron.", "# Fail")
        } else if totalFails > 0 {
            Print("Resumen: Algunas pruebas fallaron en (" Print(ctErrors, "null") ").", "# Warning")
        } else {
            Print("Resumen: Todas las pruebas pasaron con éxito.", "# Success")
        }

        if verbose {
            Print("Resumen Clases de prueba:", "")
            if (ctSuccesses.Length > 0)
                Print(" " Print(ctSuccesses, "null"), "Success")
            if (ctErrors.Length > 0)
                Print("    " Print(ctErrors, "null"), "Fail")
            if (ctNotEvaluated.Length > 0)
                Print(" " Print(ctNotEvaluated, "null"), "Warning")
            Print("total: " Print(ctTotal, "null"), "-")
        }

        return { opc: { failFast: failFast, verbose: verbose },
            total: totalTests, successes: totalSuccesses, errors: totalFails, time: elapsedTime,
            classTests: {
                successes: ctSuccesses,
                errors: ctErrors,
                notEvaluated: ctNotEvaluated,
                total: ctTotal
            }
        }
    }


    ;todo---MARK: Operations


    ;
    ;
    ;


    ;;MARK:*
    ;^----------------Operaciones Unitarias----------------^;

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
     */
    static Equal(a, b, msg := "Not Equal") {
        DUnit._methodCount++
        currentListLines := A_ListLines
        ListLines 0  ;; Desactiva temporalmente la visualización de líneas en la consola

        pa := Print(a, "null")
        pb := Print(b, "null")
        if (pa !== pb)
            throw Error(msg, -1, "('" pa "' !== '" pb "')")
        ListLines currentListLines  ;; Restaura el estado original de A_ListLines
    }

    /**
     * Verifica si dos valores no son iguales.
     * @param a Primer valor.
     * @param b Segundo valor.
     * @param msg Mensaje de error si los valores son iguales.
     */
    static NotEqual(a, b, msg := "Are Equal") {
        DUnit._methodCount++
        currentListLines := A_ListLines
        ListLines 0  ;; Desactiva temporalmente la visualización de líneas en la consola

        pa := Print(a, "null")
        pb := Print(b, "null")
        if (pa == pb)
            throw Error(msg, -1, "('" pa "' == '" pb "')")
        ListLines currentListLines  ;; Restaura el estado original de A_ListLines
    }

    /**
     * Verifica si un valor está dentro de un rango dado. Si no lo está, lanza un error con el mensaje especificado.
     * @param value Valor a verificar.
     * @param min Valor mínimo del rango.
     * @param max Valor máximo del rango.
     * @param msg Mensaje de error si el valor no está dentro del rango.
     */
    static Range(value, min, max, msg := "Value out of range") {
        if (value < min || value > max)
            throw Error(msg, -1, "Value: " value " is not between " min " and " max)
    }


    ;;MARK:*
    ;^----------------Otras Operaciones----------------^;

    /**
     * Verifica si una función lanza un error. Opcionalmente, verifica el tipo de error.
     * 
     * Este método ejecuta una función dada y verifica si lanza un error. Es posible 
     * especificar el tipo de error esperado. Si la función no lanza ningún error 
     * o lanza un tipo de error incorrecto, se genera una excepción.
     * 
     * **Nota:** Si la función a probar es un método de instancia de una clase y requiere 
     * parámetros, es importante usar `Bind` para asociar la función con la instancia 
     * (`this`) y los parámetros necesarios antes de pasarla a `Throws`.
     * 
     * @param func {Func} Función a probar. Si es un método de instancia, debe estar 
     * vinculado a su instancia (`this`) y a los parámetros usando `Bind`.
     * @param errorType {String} [errorType] Tipo de error esperado (opcional). Si se 
     * especifica, se verificará que el error lanzado sea de este tipo.
     * @param msg {String} [msg="Failed to throw correctly"] Mensaje de error que se mostrará 
     * si la función no lanza un error o si lanza un tipo de error incorrecto.
     * 
     * @example
     * ; Ejemplo de uso con un método de instancia vinculado a su contexto y parámetro.
     * DUnit.Throws(DUnitTestSuite.ThrowingFunction.Bind(this, true), "Error", "La función debería lanzar un error con true")
     * 
     * @throws {Error} Si la función no lanza un error o si el tipo de error lanzado 
     * no coincide con el `errorType` especificado.
     */
    static Throws(func, errorType?, msg := "Failed to throw correctly") {
        DUnit._methodCount++
        try {
            func()
        } catch as e {
            if IsSet(errorType) && (Type(e) != errorType)
                throw Error(msg, -1, "(incorrect error type) -> '" Type(e) "' != '" errorType "'")
            return
        }
        throw Error(msg, -1, "(no error was thrown)")  ;; Esto asegura que se lance un error si la función no lanza nada
    }


}