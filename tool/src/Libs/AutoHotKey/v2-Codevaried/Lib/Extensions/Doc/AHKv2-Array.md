# Documentación de la Librería `_Array`

Estos métodos no pueden ser usados de forma independiente. Para hacerlo, debe agregar otro argumento 'array' a la función y reemplazar todas las ocurrencias de 'this' con 'array'.

> [!IMPORTANT]  
> Ten en cuenta que el indice de cualquier Array siempre empieza en 1 y NO en 0.
> Ejemplo: `["a", "b", "c"]`
> "a" seria el indice 1, "b" el 2 y "c" el 3

## Operaciones Básicas

### `Array.Join(delimiter:=", ")`

Une todos los elementos en una cadena utilizando el delimitador proporcionado.

1. @param {String} [delimiter=", "] - El delimitador a utilizar. Por defecto es coma.

- `@returns {String}` - La cadena resultante.

#### Ejemplo

```ahk
MsgBox([1, 2, 3].Join("->"))  ; 1->2->3
```

### `Array.HasValue(valueToFind)`

Verifica si un array contiene un valor específico.

1. `@param {String}` valueToFind - El valor a buscar.

- `@returns {Boolean}` - Verdadero si el valor está en el array, falso en caso contrario.

```ahk
myArray := [1, 2, 3]
MsgBox(myArray.HasValue(2))  ; True
MsgBox(myArray.HasValue(5))  ; False
```

### `Array.Slice(start:=1, end:=0, step:=1)`

Retorna una sección del array desde 'start' hasta 'end', opcionalmente saltando elementos con 'step'. Modifica el array original.

1. `@param {Number} [start=1]` - Índice desde donde comenzar. Por defecto es 1.
2. `@param {Number} [end=0]` - Índice donde terminar. Puede ser negativo. Por defecto es 0 (incluye el último elemento).
3. `@param {Number} [step=1]` - Un entero que especifica el incremento. Por defecto es 1.

- `@returns {Array}` - La sección resultante del array.
- `@throws {Error}` - Arroja un error si el paso (step) es 0.

```ahk
slicedArray := [1, 2, 3, 4].Slice(1, 3)
MsgBox(slicedArray.Join())  ; 1, 2, 3
```

### `Array.Swap(index1, index2)`

Intercambia los elementos en los índices 'index1' y 'index2'.

1. `@param {Number} index1` - Índice del primer elemento a intercambiar.
2. `@param {Number} index2` - Índice del segundo elemento a intercambiar.

- `@returns {Array}` - El array modificado.

```ahk
swappedArray := [1, 2, 3, 4].Swap(1, 3)
MsgBox(swappedArray.Join())  ; 3, 2, 1, 4
```

### `Array.Map(func, arrays*)`

Aplica una función a cada elemento del array (modifica el array).

1. `@param {Function} func` - La función de mapeo que acepta un argumento.
2. `@param {...Array} arrays` - Arrays adicionales aceptados en la función de mapeo.

- `@returns {Array}` - El array modificado.
- `@throws {ValueError}` - Arroja un error si 'func' no es una función.

```ahk
mappedArray := [1, 2, 3].Map((n) => "( " n " )")
MsgBox(mappedArray.Join())  ; ( 1 ), ( 2 ), ( 3 )
```

### `Array.ForEach(func)`

Aplica una función a cada elemento del array.

1. `@param {Function} func` - La función de callback con argumentos Callback(value[, index, array]).

- `@returns {Array}` - El array modificado.
- `@throws {ValueError}` - Arroja un error si 'func' no es una función.

> [!WARNING]
> Se deben establecer siempre las 3 variables `(val, index, arr)` aunque no se usen, no hacer esto causará un error.

```ahk
[3, 2, 1].ForEach((val, index, arr) => MsgBox("Array: " arr.Join() "`nValue: " val ", Index: " index))
```

El código anterior mostrará 3 MsgBox:

1. **Primero**:

```MsgBox
---------------------------
Array: ( 3 ), ( 2 ), ( 1 )
Value: ( 3 ), Index: 1
---------------------------
```

2. **Segundo**:

```MsgBox
---------------------------
Array: ( 3 ), ( 2 ), ( 1 )
Value: ( 2 ), Index: 2
---------------------------
```

3. **Tercero**:

```MsgBox
---------------------------
Array: ( 3 ), ( 2 ), ( 1 )
Value: ( 1 ), Index: 3
---------------------------
```

### `Array.Filter(func)`

Conserva solo los valores que cumplen con la función proporcionada.

1. `@param {Function} func` - La función de filtro que acepta un argumento.

- `@returns {Array}` - El array filtrado.
- `@throws {ValueError}` - Arroja un error si 'func' no es una función.

```ahk
myArray := [-1, -1.1, 0, 1, 1.1]

filteredArray := myArray.Filter(IsInteger)
MsgBox(filteredArray.Join())  ; -1, 0, 1

filteredArray := myArray.Filter((v) => v > 0)
MsgBox(filteredArray.Join())  ; 1, 1.1
```

### `Array.Reduce(func, initialValue:=0)`

Aplica una función de manera acumulativa a todos los valores en el array, con un valor inicial opcional.

1. `@param {Function} func` - La función que acepta dos argumentos y retorna un valor.
2. `@param {*} [initialValue]` - El valor inicial. Si se omite, se usa el primer valor del array.

- `@returns {*}` - El valor acumulado.
- `@throws {ValueError}` - Arroja un error si 'func' no es una función.

```ahk
sum := [1, 2, 3, 4, 5].Reduce((a, b) => a + b, 0)
MsgBox(sum)  ; 15
```

### `Array.IndexOf(value, start:=1)`

Encuentra el índice de un valor en el array.

1. `@param {*} value` - El valor a buscar.
2. `@param {Number} [start=1]` - Índice desde donde comenzar la búsqueda. Por defecto es 1.

- `@returns {Number}` - El índice del valor encontrado, o 0 si no se encuentra.
- `@throws {ValueError}` - Arroja un error si 'start' no es un entero.

```ahk
index := [-5, 9, 2, 8, 1].IndexOf(2)
MsgBox(index)  ; 3
```

### `Array.Find(func, &match?, start:=1)`

Encuentra un valor que cumpla con la función proporcionada y retorna su índice.

1. `@param {Function} func` - La función de condición que acepta un argumento.
2. `@param {*} [match]` - Se establece con el valor encontrado.
3. `@param {Number} [start=1]` - Índice desde donde comenzar la búsqueda. Por defecto es 1.

- `@returns {Number}` - El índice del valor encontrado, o 0 si no se encuentra.
- `@throws {ValueError}` - Arroja un error si 'func' no es una función.

```ahk
index := [1, 2, 3, 4, 5].Find((v) => (Mod(v, 2) == 0))
MsgBox(index)  ; 2
```

### `Array.Unique()`

Genera un array con elementos únicos.

- `@returns {Array}` - Un array con elementos únicos.

```ahk
uniqueArray := [1, 1, 2, 2, 3, 3, 4, 4, 5, 5].Unique()
MsgBox(uniqueArray.Join())  ; 1, 2, 3, 4, 5
```

## Algoritmos de Mezcla

### `Array.Shuffle()`

Baraja el array. Más rápido que `Array.Sort(,"Random N")`.

- `@returns {Array}` - El array barajado.

```ahk
myArray := ["a", 1, 2, 3, "a"]
shuffledArray := myArray.Shuffle()
MsgBox(shuffledArray.Join())  ; Salida aleatoria, por ejemplo: 2, a, 3, 1, a
```

### `Array.Reverse()`

Invierte el array.

- `@returns {Array}` - El array invertido.

```ahk
reversedArray := [1, 2, 3, 4, 5].Reverse()
MsgBox(reversedArray.Join())  ; 5, 4, 3, 2, 1
```

### `Array.Count(value)`

Cuenta el número de ocurrencias de un valor.

1. `@param {*} value` - El valor a contar. También puede ser una función.

- `@returns {Number}` - El número de ocurrencias.

```ahk
count := [1, 2, 3, 4, 1, 2, 1].Count(1)
MsgBox(count)  ; 3
```

### `Array.Flat()`

Convierte un array anidado en un array de un solo nivel.

- `@returns {Array}` - El array plano.

```ahk
nestedArray := [1, [2, [3, 4]], 5]
flatArray := nestedArray.Flat()
MsgBox(flatArray.Join())  ; 1, 2, 3, 4, 5
```

### `Array.Extend(...arrays)`

Agrega el contenido de otro array al final de este.

1. `@param {...Array} enums` - Los arrays u otros enumerables que se usan para extender este.

- `@returns {Array}` - El array extendido.

```ahk
extendedArray := [1, 2, 3].Extend([4, 5], [6, 7])
MsgBox(extendedArray.Join())  ; 1, 2, 3, 4, 5, 6, 7
```

## Algoritmos de Ordenamiento

### `Array.Sort(optionsOrCallback := "N", key?)`

Ordena un array, opcionalmente por claves de objeto.

1. `@param {String|Function} [optionsOrCallback="N"]` - Una función de callback, o una de las siguientes opciones:
   - `N` => El array se considera que consiste solo en valores numéricos. Esta es la opción por defecto.
   - `C, C1 o COn` => Ordenación sensible a mayúsculas y minúsculas de cadenas.
   - `C0 o COff` => Ordenación insensible a mayúsculas y minúsculas de cadenas.
   - La función de callback debe aceptar dos parámetros `elem1` y `elem2` y retornar un entero:
     - Retornar entero < 0 si `elem1` es menor que `elem2`.
     - Retornar 0 si `elem1` es igual a `elem2`.
     - Retornar > 0 si `elem1` es mayor que `elem2`.
2. `@param {String} [key]` - Si tienes un array de objetos, especifica aquí la clave por la que se ordenarán los contenidos del objeto.

- `@returns {Array}` - El array ordenado.
- `@throws {ValueError}` - Arroja un error si no se proporcionan opciones válidas.

```ahk
myArray := [4, 2, 7, 1, 3, -1]
sortedArray := myArray.Sort("N")
MsgBox(sortedArray.Join())  ; -1, 1, 2, 3, 4, 7
```

## Generación de Arrays con 'ArrayUtiles'

Esta clase es independiente y se utiliza usando sus métodos estáticos.

### `ArrayUtiles.Combine(...arrays)`

Combina múltiples arrays en uno solo.

1. `@param {...Array} arrays` - Uno o más arrays a combinar.

- `@returns {Array}` - Un nuevo array que contiene todos los elementos de los arrays proporcionados.

```ahk
combinedArray := ArrayUtiles.Combine([1, 2, 3], [4, 5, 6])
MsgBox(combinedArray.Join())  ; 1, 2, 3, 4, 5, 6
```

### `ArrayUtiles.GenerateRandom(size, variation := 7)`

Genera un array con números aleatorios.

1. `@param {Number} indexes` - La cantidad de elementos del array.
2. `@param {Number} [variation=7]` - El rango de variación para los números aleatorios.

- `@returns {Array}` - El array generado con números aleatorios.

```ahk
randomArray := ArrayUtiles.GenerateRandom(10)
MsgBox(randomArray.Join())  ; Salida aleatoria, por ejemplo: 7, 3, 1, 9, 4, 6, 0, 8, 5, 2
```

### `ArrayUtiles.GenerateRising(size)`

Genera un array en orden ascendente.

1. `@param {Number} indexes` - La cantidad de elementos del array.

- `@returns {Array}` - El array generado con números en orden ascendente.

```ahk
risingArray := ArrayUtiles.GenerateRising(10)
MsgBox(risingArray.Join())  ; 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
```

### `ArrayUtiles.GenerateShuffled(size)`

Genera un array en orden ascendente y luego barajado.

1. `@param {Number} indexes` - La cantidad de elementos del array.

- `@returns {Array}` - El array generado y barajado.

```ahk
shuffledRisingArray := ArrayUtiles.GenerateShuffled(10)
MsgBox(shuffledRisingArray.Join())  ; Salida aleatoria, por ejemplo: 4, 10, 1, 6, 2, 7, 5, 9, 8, 3
```
