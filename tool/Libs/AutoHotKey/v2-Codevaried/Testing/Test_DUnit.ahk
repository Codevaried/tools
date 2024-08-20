class DUnitTestSuite {

    ;; Este método se ejecuta antes de cualquier prueba en la clase
    Init() {
        Print("Inicializando el entorno de pruebas...")
    }

    ;; Este método se ejecuta después de que todas las pruebas en la clase hayan terminado
    End() {
        Print("Finalizando el entorno de pruebas...")
    }

    ;; Prueba 1: Verifica que una condición verdadera pase
    Test_TrueCondition() {
        DUnit.True(1 = 1, "1 debería ser igual a 1")
    }

    ;; Prueba 2: Verifica que una condición falsa falle
    Test_FalseCondition() {
        DUnit.False(1 = 2, "1 no debería ser igual a 2")
    }

    ;; Prueba 3: Verifica que dos valores sean iguales
    Test_EqualValues() {
        DUnit.Equal(5, 5, "Los valores deberían ser iguales")
    }

    ;; Prueba 4: Verifica que dos valores no sean iguales
    Test_NotEqualValues() {
        DUnit.NotEqual(5, 10, "Los valores no deberían ser iguales")
    }

    ;; Prueba 5: Verifica que un valor esté dentro de un rango específico
    Test_ValueInRange() {
        DUnit.Range(7, 5, 10, "El valor debería estar entre 5 y 10")
    }

    ;; Prueba 6: Verifica que una función lanza un error con un parámetro
    Test_FunctionThrowsError() {
        ;; Lanza un error genérico
        DUnit.Throws(DUnitTestSuite.ThrowingFunction.Bind(this, 0), "Error", "La función debería lanzar un Error con 0")

        ;; Lanza un TypeError
        DUnit.Throws(DUnitTestSuite.ThrowingFunction.Bind(this, 1), "TypeError", "La función debería lanzar un TypeError con 1")

        ;;* Este tests fallará porque no lanza ningún error
        ; DUnit.Throws(DUnitTestSuite.ThrowingFunction.Bind(this))
    }

    /**
     * Función auxiliar que lanza un error basado en el valor de `e`.
     * @param e (Opcional) Valor que determina el tipo de error a lanzar.
     *   - Si `e` es 0, lanza un `Error`.
     *   - Si `e` es 1, lanza un `TypeError`.
     *   - Si `e` no está definido o tiene otro valor, no lanza ningún error.
     */
    static ThrowingFunction(e?) {
        if IsSet(e) {
            switch e {
                case 0:
                    throw Error("Este es un error esperado")
                case 1:
                    throw TypeError("Este es un error esperado")
            }
        }
    }
}