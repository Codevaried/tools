# Documentación de la Librería `_Map`

Estos métodos no pueden ser usados de forma independiente. Para hacerlo, debe agregar otro argumento 'map' a la función y reemplazar todas las ocurrencias de 'this' con 'map'.

## Operaciones Básicas

### `Map.Join(delimiter := ", ")`

Convierte un mapa en una cadena, uniendo los pares clave-valor con un carácter especificado.

1. `@param {String} [delimiter=", "]` - El carácter para separar los pares clave-valor en la cadena. Por defecto es coma y espacio.

- `@returns {String}` - La cadena resultante.

#### Ejemplo

```ahk
myMap := Map()
myMap.Set("a", 1)
myMap.Set("b", 2)
MsgBox(myMap.Join(" -> "))  ; "a: 1 -> b: 2"
```

### `Map.SafeSet(mapObj, key, value)`

Establece un par clave-valor en un mapa de manera segura, arrojando un error si la clave ya existe.

1. `@param {Map} mapObj` - El mapa en el que se establecerá el par clave-valor.
2. `@param {String} key` - La clave a establecer en el mapa.
3. `@param {Any} value` - El valor a establecer para la clave.

- `@throws {IndexError}` - Arroja un error si la clave ya existe en el mapa.

#### Ejemplo

```ahk
try {
    myMap.SafeSet(myMap, "c", 3)
    MsgBox("Method: SafeSet`nResult: Success")
} catch IndexError as e {
    MsgBox("Method: SafeSet`nError: " e.message)
}

try {
    myMap.SafeSet(myMap, "a", 10)
} catch IndexError as e {
    MsgBox("Method: SafeSet`nError: " e.message)
}
```

### `Map.SafeSetMap(mapObj, mapToSet)`

Establece todos los pares clave-valor de un mapa en otro mapa de manera segura, arrojando un error para cada clave que ya exista en el mapa.

1. `@param {Map} mapObj` - El mapa inicial.
2. `@param {Map} mapToSet` - El mapa que se establecerá en el mapa inicial.

- `@throws {IndexError}` - Arroja un error por cada clave que ya exista en el mapa.

#### Ejemplo

```ahk
newMap := Map()
newMap.Set("d", 4)
newMap.Set("e", 5)

try {
    myMap.SafeSetMap(myMap, newMap)
    MsgBox("Method: SafeSetMap`nResult: Success")
} catch IndexError as e {
    MsgBox("Method: SafeSetMap`nError: " e.message)
}
```

### `Map.Reverse(mapObj)`

Invierte las claves y valores en un mapa.

1. `@param {Map} mapObj` - El mapa a invertir.

- `@returns {Map}` - El mapa invertido.

#### Ejemplo

```ahk
try {
    reversedMap := myMap.Reverse(myMap)
    MsgBox("Method: Reverse`nResult: " reversedMap.Join())
} catch Error as e {
    MsgBox("Method: Reverse`nError: " e.message)
}
```
