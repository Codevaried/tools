# Documentación de la Librería `_String`

Estos métodos no pueden ser usados de forma independiente. Para hacerlo, debe agregar otro argumento 'string' a la función y reemplazar todas las ocurrencias de 'this' con 'string'.

## Propiedades

### `String.Length`

La longitud de la cadena.

1. `@returns {Number}` - La longitud de la cadena.

```ahk
s := "Hola"
MsgBox s.Length  ; 4
```

### `String.IsDigit`

Verifica si la cadena contiene solo dígitos.

1. `@returns {Boolean}` - Verdadero si la cadena contiene solo dígitos, falso en caso contrario.

```ahk
s := "12345"
MsgBox s.IsDigit  ; true
```

### `String.IsXDigit`

Verifica si la cadena contiene solo dígitos hexadecimales.

1. `@returns {Boolean}` - Verdadero si la cadena contiene solo dígitos hexadecimales, falso en caso contrario.

```ahk
s := "1A3F"
MsgBox s.IsXDigit  ; true
```

### `String.IsAlpha`

Verifica si la cadena contiene solo caracteres alfabéticos.

1. `@returns {Boolean}` - Verdadero si la cadena contiene solo caracteres alfabéticos, falso en caso contrario.

```ahk
s := "Hola"
MsgBox s.IsAlpha  ; true
```

### `String.IsUpper`

Verifica si la cadena contiene solo caracteres en mayúsculas.

1. `@returns {Boolean}` - Verdadero si la cadena contiene solo caracteres en mayúsculas, falso en caso contrario.

```ahk
s := "HOLA"
MsgBox s.IsUpper  ; true
```

### `String.IsLower`

Verifica si la cadena contiene solo caracteres en minúsculas.

1. `@returns {Boolean}` - Verdadero si la cadena contiene solo caracteres en minúsculas, falso en caso contrario.

```ahk
s := "hola"
MsgBox s.IsLower  ; true
```

### `String.IsAlnum`

Verifica si la cadena contiene solo caracteres alfanuméricos.

1. `@returns {Boolean}` - Verdadero si la cadena contiene solo caracteres alfanuméricos, falso en caso contrario.

```ahk
s := "Hola123"
MsgBox s.IsAlnum  ; true
```

### `String.IsSpace`

Verifica si la cadena contiene solo caracteres de espacio.

1. `@returns {Boolean}` - Verdadero si la cadena contiene solo caracteres de espacio, falso en caso contrario.

```ahk
s := "   "
MsgBox s.IsSpace  ; true
```

### `String.IsTime`

Verifica si la cadena tiene un formato de tiempo válido.

1. `@returns {Boolean}` - Verdadero si la cadena tiene un formato de tiempo válido, falso en caso contrario.

```ahk
s := "12:34"
MsgBox s.IsTime  ; true
```

## Métodos

### `String.ToUpper()`

Convierte la cadena a mayúsculas.

1. `@returns {String}` - La cadena convertida a mayúsculas.

```ahk
s := "hola"
MsgBox s.ToUpper()  ; "HOLA"
```

### `String.ToLower()`

Convierte la cadena a minúsculas.

1. `@returns {String}` - La cadena convertida a minúsculas.

```ahk
s := "HOLA"
MsgBox s.ToLower()  ; "hola"
```

### `String.ToTitle()`

Convierte la cadena a formato título.

1. `@returns {String}` - La cadena convertida a formato título.

```ahk
s := "hola mundo"
MsgBox s.ToTitle()  ; "Hola Mundo"
```

### `String.Split([Delimiters, OmitChars, MaxParts])`

Divide la cadena en un arreglo.

1. `@param {String} [Delimiters]` - Delimitadores para dividir la cadena.
2. `@param {String} [OmitChars]` - Caracteres a omitir.
3. `@param {Number} [MaxParts]` - Número máximo de partes en que dividir.

- `@returns {Array}` - El arreglo resultante.

```ahk
s := "Hola, Mundo"
arr := s.Split(", ")
MsgBox arr[1]  ; "Hola"
MsgBox arr[2]  ; "Mundo"
```

### `String.Replace(Needle [, ReplaceText, CaseSense, &OutputVarCount, Limit])`

Reemplaza ocurrencias de una subcadena.

1. `@param {String} Needle` - Subcadena a reemplazar.
2. `@param {String} [ReplaceText]` - Texto de reemplazo.
3. `@param {Boolean} [CaseSense]` - Si es sensible a mayúsculas y minúsculas.
4. `@param {Number} [&OutputVarCount]` - Variable de salida para contar reemplazos.
5. `@param {Number} [Limit]` - Número máximo de reemplazos.

- `@returns {String}` - La cadena con las reemplazos realizados.

```ahk
s := "Hola Mundo"
MsgBox s.Replace("Mundo", "Amigo")  ; "Hola Amigo"
```

### `String.Trim([OmitChars])`

Recorta los espacios en blanco u otros caracteres especificados de ambos extremos de la cadena.

1. `@param {String} [OmitChars]` - Caracteres a omitir.

- `@returns {String}` - La cadena recortada.

```ahk
s := "  Hola  "
MsgBox s.Trim()  ; "Hola"
```

### `String.LTrim([OmitChars])`

Recorta los espacios en blanco u otros caracteres especificados del extremo izquierdo de la cadena.

1. `@param {String} [OmitChars]` - Caracteres a omitir.

- `@returns {String}` - La cadena recortada.

```ahk
s := "  Hola"
MsgBox s.LTrim()  ; "Hola"
```

### `String.RTrim([OmitChars])`

Recorta los espacios en blanco u otros caracteres especificados del extremo derecho de la cadena.

1. `@param {String} [OmitChars]` - Caracteres a omitir.

- `@returns {String}` - La cadena recortada.

```ahk
s := "Hola  "
MsgBox s.RTrim()  ; "Hola"
```

### `String.Compare(comparison [, CaseSense])`

Compara dos cadenas.

1. `@param {String} comparison` - La cadena con la que se compara.
2. `@param {Boolean} [CaseSense]` - Si es sensible a mayúsculas y minúsculas.

- `@returns {Number}` - 0 si son iguales, 1 si es mayor, -1 si es menor.

```ahk
s := "Hola"
MsgBox s.Compare("hola")  ; 0 (si no es sensible a mayúsculas/minúsculas)
```

### `String.Sort([, Options, Function])`

Ordena la cadena.

1. `@param {String|Function} [Options]` - Opciones de ordenamiento o función de comparación.
2. `@param {Function} [Function]` - Función de comparación.

- `@returns {String}` - La cadena ordenada.

```ahk
s := "cba"
MsgBox s.Sort()  ; "abc"
```

### `String.Format([Values...])`

Formatea la cadena.

1. `@param {...*} [Values]` - Valores para formatear la cadena.

- `@returns {String}` - La cadena formateada.

```ahk
s := "{1} {2}"
MsgBox s.Format("Hola", "Mundo")  ; "Hola Mundo"
```

### `String.Find(Needle [, CaseSense, StartingPos, Occurrence])`

Encuentra una subcadena dentro de la cadena.

1. `@param {String} Needle` - Subcadena a buscar.
2. `@param {Boolean} [CaseSense]` - Si es sensible a mayúsculas y minúsculas.
3. `@param {Number} [StartingPos]` - Posición de inicio para la búsqueda.
4. `@param {Number} [Occurrence]` - Ocurrencia específica a encontrar.

- `@returns {Number}` - La posición de la subcadena encontrada.

```ahk
s := "Hola Mundo"
MsgBox s.Find("Mundo")  ; 6
```

### `String.SplitPath()`

Divide la cadena en componentes de ruta y devuelve un objeto con las propiedades `FileName`, `Dir`, `Ext`, `NameNoExt` y `Drive`.

- `@returns {Object}` - El objeto con los componentes de la ruta.

#### Propiedades del objeto retornado:

- `FileName`: El nombre del archivo sin la ruta.
- `Dir`: El directorio del archivo, incluyendo la letra de la unidad o el nombre del recurso compartido (si está presente). El último backslash no está incluido.
- `Ext`: La extensión del archivo (por ejemplo, TXT, DOC, EXE). El punto no está incluido.
- `NameNoExt`: El nombre del archivo sin su ruta, punto y extensión.
- `Drive`: La letra de la unidad o el nombre del servidor del archivo. Si el archivo está en una unidad local o mapeada, la variable se establece en la letra de la unidad seguida de dos puntos (sin backslash). Si el archivo está en una ruta de red (UNC), la variable se establece en el nombre del recurso compartido, por ejemplo, `\\Workstation01`.

```ahk
s := "C:\path\to\file.txt"
obj := s.SplitPath()
MsgBox "FileName: " obj.FileName  ; "file.txt"
MsgBox "Dir: " obj.Dir  ; "C:\path\to"
MsgBox "Ext: " obj.Ext  ; "txt"
MsgBox "NameNoExt: " obj.NameNoExt  ; "file"
MsgBox "Drive: " obj.Drive  ; "C:"
```

### `String.RegExMatch(needleRegex, &match?, startingPos?)`

Coincide una expresión regular con la cadena.

1. `@param {String} needleRegex` - Patrón a coincidir.
2. `@param {Object} [&match]` - Objeto para almacenar la coincidencia.
3. `@param {Number} [startingPos]` - Posición de inicio para la coincidencia.

- `@returns {Object}` - El objeto de coincidencia.

```ahk
s := "abc123"
if s.RegExMatch("\

d+", &m)
    MsgBox m  ; "123"
```

### `String.RegExMatchAll(needleRegex, startingPos?)`

Coincide todas las ocurrencias de una expresión regular con la cadena.

1. `@param {String} needleRegex` - Patrón de expresión regular a buscar.
2. `@param {Number} [startingPos]` - Posición de inicio para la coincidencia.

- `@returns {Array}` - Arreglo con todos los resultados de coincidencia.

```ahk
s := "abc123def456"
matches := s.RegExMatchAll("\d+")
for match in matches
    MsgBox match  ; Muestra "123" y luego "456"
```

### `String.RegExReplace(needle, replacement?, &count?, limit?, startingPos?)`

Reemplaza ocurrencias de una expresión regular.

1. `@param {String} needle` - Patrón a coincidir.
2. `@param {String} [replacement]` - Texto para reemplazar la coincidencia.
3. `@param {Number} [&count]` - Variable de salida para contar los reemplazos.
4. `@param {Number} [limit]` - Número máximo de reemplazos.
5. `@param {Number} [startingPos]` - Posición de inicio para la coincidencia.

- `@returns {String}` - La cadena modificada.

```ahk
s := "abc123"
MsgBox s.RegExReplace("\d+", "456")  ; "abc456"
```

### `String[n]`

Obtiene el n-ésimo carácter de la cadena.

1. `@param {Number} n` - El índice del carácter a obtener.

- `@returns {String}` - El carácter en la posición especificada.

```ahk
s := "Hola"
MsgBox s[2]  ; "o"
```

### `String[i,j]`

Obtiene la subcadena de i a j.

1. `@param {Number} i` - Índice de inicio.
2. `@param {Number} j` - Índice de fin.

- `@returns {String}` - La subcadena desde el índice i hasta el j.

```ahk
s := "Hola Mundo"
MsgBox s[1,4]  ; "Hola"
```

### `for [index,] char in String`

Itera sobre los caracteres en la cadena.

- `@returns {Iterator}` - Iterador para los caracteres en la cadena.

```ahk
s := "Hola"
for index, char in s
    MsgBox char  ; Muestra "H", luego "o", luego "l", luego "a"
```

### `String.Count(searchFor)`

Cuenta las ocurrencias de una subcadena.

1. `@param {String} searchFor` - La subcadena a buscar.

- `@returns {Number}` - El número de ocurrencias de la subcadena.

```ahk
s := "Hola Hola"
MsgBox s.Count("Hola")  ; 2
```

### `String.Insert(insert, into [, pos])`

Inserta una subcadena en una posición especificada.

1. `@param {String} insert` - El texto a insertar.
2. `@param {Number} [pos]` - La posición donde insertar el texto.

- `@returns {String}` - La cadena con el texto insertado.

```ahk
s := "Hola"
MsgBox s.Insert(" Mundo", 5)  ; "Hola Mundo"
```

### `String.Delete(string [, start, length])`

Elimina una subcadena de la cadena.

1. `@param {Number} [start]` - La posición de inicio para eliminar.
2. `@param {Number} [length]` - La longitud de la subcadena a eliminar.

- `@returns {String}` - La cadena con la subcadena eliminada.

```ahk
s := "Hola Mundo"
MsgBox s.Delete(5, 6)  ; "Hola"
```

### `String.Overwrite(overwrite, into [, pos])`

Sobrescribe una subcadena en una posición especificada.

1. `@param {String} overwrite` - El texto para sobrescribir.
2. `@param {Number} [pos]` - La posición donde sobrescribir el texto.

- `@returns {String}` - La cadena con el texto sobrescrito.

```ahk
s := "Hola Mundo"
MsgBox s.Overwrite("Amigo", 6)  ; "Hola Amigo"
```

### `String.Repeat(count)`

Repite la cadena un número especificado de veces.

1. `@param {Number} count` - El número de repeticiones.

- `@returns {String}` - La cadena repetida.

```ahk
s := "Hola"
MsgBox s.Repeat(3)  ; "HolaHolaHola"
```

### `String.Concat(words*)`

Concatena múltiples cadenas con un delimitador.

1. `@param {String} delimiter` - El delimitador a utilizar.
2. `@param {...String} words` - Las cadenas a concatenar.

- `@returns {String}` - La cadena concatenada.

```ahk
d := ", "
MsgBox d.Concat("Hola", "Mundo", "!")
; "Hola, Mundo, !"
```

### `String.LineWrap([column:=56, indentChar:=""])`

Ajusta la cadena en líneas de una anchura de columna especificada.

1. `@param {Number} [column=56]` - La longitud máxima por línea.
2. `@param {String} [indentChar=""]` - El carácter para indentar las líneas siguientes.

- `@returns {String}` - La cadena ajustada.

```ahk
s := "Esto es un ejemplo de una cadena muy larga que necesita ser ajustada en líneas más cortas."
MsgBox s.LineWrap(20, "---")
; Muestra "Esto es un ejemplo de
; ---una cadena muy larga que
; ---necesita ser ajustada en
; ---líneas más cortas."
```

### `String.WordWrap([column:=56, indentChar:=""])`

Ajusta la cadena en palabras de una anchura de columna especificada.

1. `@param {Number} [column=56]` - La longitud máxima por línea.
2. `@param {String} [indentChar=""]` - El carácter para indentar las líneas siguientes.

- `@returns {String}` - La cadena ajustada.

```ahk
s := "Esto es un ejemplo de una cadena muy larga que necesita ser ajustada en palabras más cortas."
MsgBox s.WordWrap(20, "---")
; Muestra "Esto es un ejemplo
; ---de una cadena muy
; ---larga que necesita ser
; ---ajustada en palabras
; ---más cortas."
```

### `` String.ReadLine(line [, delim:="`n", exclude:="`r"]) ``

Lee una línea específica de la cadena.

1. `@param {Number|String} line` - El número de línea a leer.
2. `` @param {String} [delim="`n"] `` - El delimitador de línea.
3. `` @param {String} [exclude="`r"] `` - El carácter a excluir.

- `@returns {String}` - La línea leída.

```ahk
s := "Línea 1`nLínea 2`nLínea 3"
MsgBox s.ReadLine(2)  ; "Línea 2"
```

### `` String.DeleteLine(line [, delim:="`n", exclude:="`r"]) ``

Elimina una línea específica de la cadena.

1. `@param {Number|String} line` - El número de línea a eliminar.
2. `` @param {String} [delim="`n"] `` - El delimitador de línea.
3. `` @param {String} [exclude="`r"] `` - El carácter a excluir.

- `@returns {String}` - La cadena con la línea eliminada.

```ahk
s := "Línea 1`nLínea 2`nLínea 3"
MsgBox s.DeleteLine(2)  ; "Línea 1`nLínea 3"
```

### `` String.InsertLine(insert, into, line [, delim:="`n", exclude:="`r"]) ``

Inserta una línea en la cadena.

1. `@param {String} insert` - El texto a insertar.
2. `@param {String} into` - La cadena en la que insertar la línea.
3. `@param {Number|String} line` - El número de línea en el que insertar.
4. `` @param {String} [delim="`n"] `` - El delimitador de línea.
5. `` @param {String} [exclude="`r"] `` - El carácter a excluir.

- `@returns {String}` - La cadena con la línea insertada.

```ahk
s := "Línea 1`nLínea 3"
MsgBox s.InsertLine("Línea 2", 2)  ; "Línea 1`nLínea 2`nLínea 3"
```

### `String.Reverse()`

Invierte la cadena.

- `@returns {String}` - La cadena invertida.

```ahk
s := "Hola"
MsgBox s.Reverse()  ; "aloH"
```

### `String.Contains(needle1 [, needle2, needle3...])`

Verifica si la cadena contiene alguna de las

subcadenas especificadas.

1. `@param {...String} needles` - Las subcadenas a buscar.

- `@returns {Boolean}` - Verdadero si alguna subcadena está contenida, falso en caso contrario.

```ahk
s := "Hola Mundo"
MsgBox s.Contains("Mundo", "Amigo")  ; true
```

### `` String.RemoveDuplicates([delim:="`n"]) ``

Elimina líneas duplicadas de la cadena.

1. `` @param {String} [delim="`n"] `` - El delimitador de línea.

- `@returns {String}` - La cadena sin duplicados.

```ahk
s := "Línea 1`nLínea 2`nLínea 1"
MsgBox s.RemoveDuplicates()  ; "Línea 1`nLínea 2"
```

### `String.LPad(count)`

Rellena la cadena con espacios u otros caracteres especificados a la izquierda.

1. `@param {Number} count` - El número de veces para repetir el carácter de relleno.

- `@returns {String}` - La cadena con relleno a la izquierda.

```ahk
s := "Hola"
MsgBox s.LPad(10)  ; "      Hola"
```

### `String.RPad(count)`

Rellena la cadena con espacios u otros caracteres especificados a la derecha.

1. `@param {Number} count` - El número de veces para repetir el carácter de relleno.

- `@returns {String}` - La cadena con relleno a la derecha.

```ahk
s := "Hola"
MsgBox s.RPad(10)  ; "Hola      "
```

### `` String.Center([fill:=" ", symFill:=0, delim:="`n", exclude:="`r", width]) ``

Centra la cadena dentro de una anchura especificada.

1. `@param {String} [fill=" "]` - El carácter de relleno.
2. `@param {Boolean} [symFill=0]` - Si rellenar ambos lados (1) o solo la izquierda (0).
3. `` @param {String} [delim="`n"] `` - El delimitador de línea.
4. `` @param {String} [exclude="`r"] `` - El carácter a excluir.
5. `@param {Number} [width]` - La anchura especificada.

- `@returns {String}` - La cadena centrada.

```ahk
s := "Hola"
MsgBox s.Center(10)  ; "   Hola   "
```

### `` String.Right([fill:=" ", delim:="`n", exclude:="`r"]) ``

Alinea la cadena a la derecha dentro de una anchura especificada.

1. `@param {String} [fill=" "]` - El carácter de relleno.
2. `` @param {String} [delim="`n"] `` - El delimitador de línea.
3. `` @param {String} [exclude="`r"] `` - El carácter a excluir.

- `@returns {String}` - La cadena alineada a la derecha.

```ahk
s := "Hola"
MsgBox s.Right(10)  ; "      Hola"
```
