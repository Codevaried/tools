;todo---MARK: Class _Array


Array.Prototype.base := _Array

/**
 * Clase personalizada que extiende la funcionalidad del Array nativo de AutoHotkey.
 * Proporciona métodos adicionales para manipular arrays.
 * 
 * @class _Array
 * @extends Array
 */
class _Array extends Array {


	;;MARK:#
	;^----------------Extended Methods----------------^;


	;
	;
	;


	;;MARK:*
	;? Section: Basic Operations

	/**
	 * Une todos los elementos en una cadena utilizando el delimitador proporcionado.
	 * @param {String} [delim=", "] - El delimitador a utilizar. Por defecto es coma.
	 * @returns {String} - La cadena resultante.
	 */
	static Join(delim := ", ") {
		result := ""
		for v in this
			result .= v delim
		return (len := StrLen(delim)) ? SubStr(result, 1, -len) : result
	}

	/**
	 * Verifica si un array contiene un valor específico.
	 * @param {String} valueToFind - El valor a buscar.
	 * @returns {Boolean} - Verdadero si el valor está en el array, falso en caso contrario.
	 */
	static HasValue(valueToFind) {
		for item in this {
			if (item = valueToFind)
				return true
		}
		return false
	}

	/**
	 * Genera un array con elementos únicos.
	 * @returns {Array} - Un array con elementos únicos.
	 */
	static Unique() {
		unique := Map()
		for v in this
			unique[v] := 1
		return [unique*]
	}

	/**
	 * Retorna una sección del array desde 'start' hasta 'end', opcionalmente saltando elementos con 'step'.
	 * Modifica el array original.
	 * @param {Number} [start=1] - Índice desde donde comenzar. Por defecto es 1.
	 * @param {Number} [end=0] - Índice donde terminar. Puede ser negativo. Por defecto es 0 (incluye el último elemento).
	 * @param {Number} [step=1] - Un entero que especifica el incremento. Por defecto es 1.
	 * @returns {Array} - La sección resultante del array.
	 * @throws {Error} - Arroja un error si el paso (step) es 0.
	 */
	static Slice(start := 1, end := 0, step := 1) {
		len := this.Length, i := start < 1 ? len + start : start, j := Min(end < 1 ? len + end : end, len), r := [], reverse := False
		if len = 0
			return []
		if i < 1
			i := 1
		if step = 0
			Throw Error("Slice: step cannot be 0", -1)
		else if step < 0 {
			while i >= j {
				r.Push(this[i])
				i += step
			}
		} else {
			while i <= j {
				r.Push(this[i])
				i += step
			}
		}
		return this := r
	}

	/**
	 * Intercambia los elementos en los índices a y b.
	 * @param {Number} a - Índice del primer elemento a intercambiar.
	 * @param {Number} b - Índice del segundo elemento a intercambiar.
	 * @returns {Array} - El array modificado.
	 */
	static Swap(a, b) {
		temp := this[b]
		this[b] := this[a]
		this[a] := temp
		return this
	}

	/**
	 * Aplica una función a cada elemento del array (modifica el array).
	 * @param {Function} func - La función de mapeo que acepta un argumento.
	 * @param {...Array} arrays - Arrays adicionales aceptados en la función de mapeo.
	 * @returns {Array} - El array modificado.
	 */
	static Map(func, arrays*) {
		if !HasMethod(func)
			throw ValueError("Map: func must be a function", -1)
		for i, v in this {
			bf := func.Bind(v?)
			for _, vv in arrays
				bf := bf.Bind(vv.Has(i) ? vv[i] : unset)
			try bf := bf()
			this[i] := bf
		}
		return this
	}

	/**
	 * Aplica una función a cada elemento del array.
	 * @param {Function} func - La función de callback con argumentos Callback(value[, index, array]).
	 * @returns {Array} - El array modificado.
	 */
	static ForEach(func) {
		if !HasMethod(func)
			throw ValueError("ForEach: func must be a function", -1)
		for i, v in this
			func(v, i, this)
		return this
	}

	/**
	 * Conserva solo los valores que cumplen con la función proporcionada.
	 * @param {Function} func - La función de filtro que acepta un argumento.
	 * @returns {Array} - El array filtrado.
	 * @throws {ValueError} - Arroja un error si 'func' no es una función. 
	 */
	static Filter(func) {
		if !HasMethod(func)
			throw ValueError("Filter: func must be a function", -1)
		r := []
		for v in this
			if func(v)
				r.Push(v)
		return this := r
	}

	/**
	 * Aplica una función de manera acumulativa a todos los valores en el array, con un valor inicial opcional.
	 * @param {Function} func - La función que acepta dos argumentos y retorna un valor.
	 * @param {*} [initialValue] - El valor inicial. Si se omite, se usa el primer valor del array.
	 * @returns {*} - El valor acumulado.
	 * @throws {ValueError} - Arroja un error si 'func' no es una función.
	 * 
	 * @example
	 * [1,2,3,4,5].Reduce((a,b) => (a+b)) ; retorna 15 (la suma de todos los números)
	 */
	static Reduce(func, initialValue?) {
		if !HasMethod(func)
			throw ValueError("Reduce: func must be a function", -1)
		len := this.Length + 1
		if len = 1
			return initialValue ?? ""
		if IsSet(initialValue)
			out := initialValue, i := 0
		else
			out := this[1], i := 1
		while ++i < len {
			out := func(out, this[i])
		}
		return out
	}

	/**
	 * Encuentra un valor en el array y retorna su índice.
	 * @param {*} value - El valor a buscar.
	 * @param {Number} [start=1] - Índice desde donde comenzar la búsqueda. Por defecto es 1.
	 * @returns {Number} - El índice del valor encontrado, o 0 si no se encuentra.
	 * @throws {ValueError} - Arroja un error si 'start' no es un entero. 
	 */
	static IndexOf(value, start := 1) {
		if !IsInteger(start)
			throw ValueError("IndexOf: start value must be an integer")
		for i, v in this {
			if i < start
				continue
			if v == value
				return i
		}
		return 0
	}

	/**
	 * Encuentra un valor que cumpla con la función proporcionada y retorna su índice.
	 * @param {Function} func - La función de condición que acepta un argumento.
	 * @param {*} [match] - Se establece con el valor encontrado.
	 * @param {Number} [start=1] - Índice desde donde comenzar la búsqueda. Por defecto es 1.
	 * @returns {Number} - El índice del valor encontrado, o 0 si no se encuentra.
	 * @throws {ValueError} - Arroja un error si 'func' no es una función. 
	 * @example
	 * [1,2,3,4,5].Find((v) => (Mod(v,2) == 0)) ; retorna 2
	 */
	static Find(func, &match?, start := 1) {
		if !HasMethod(func)
			throw ValueError("Find: func must be a function", -1)
		for i, v in this {
			if i < start
				continue
			if func(v) {
				match := v
				return i
			}
		}
		return 0
	}


	;;MARK:*
	;? Section: Shuffling Algorithm

	/**
	 * Baraja el array. Más rápido que Array.Sort(,"Random N").
	 * @returns {Array} - El array barajado.
	 */
	static Shuffle() {
		len := this.Length
		Loop len - 1
			this.Swap(A_index, Random(A_index, len))
		return this
	}

	/**
	 * Invierte el array.
	 * @example
	 * [1,2,3].Reverse() ; retorna [3,2,1]
	 * @returns {Array} - El array invertido.
	 */
	static Reverse() {
		len := this.Length + 1, max := (len // 2), i := 0
		while ++i <= max
			this.Swap(i, len - i)
		return this
	}

	/**
	 * Cuenta el número de ocurrencias de un valor.
	 * @param {*} value - El valor a contar. También puede ser una función.
	 * @returns {Number} - El número de ocurrencias.
	 */
	static Count(value) {
		count := 0
		if HasMethod(value) {
			for _, v in this
				if value(v?)
					count++
		} else
			for _, v in this
				if v == value
					count++
		return count
	}

	/**
	 * Convierte un array anidado en un array de un solo nivel.
	 * @returns {Array} - El array plano.
	 * @example
	 * [1,[2,[3]]].Flat() ; retorna [1,2,3]
	 */
	static Flat() {
		r := []
		for v in this {
			if Type(v) = "Array"
				r.Extend(v.Flat())
			else
				r.Push(v)
		}
		return this := r
	}

	/**
	 * Agrega el contenido de otro array al final de este.
	 * @param {...Array} enums - Los arrays u otros enumerables que se usan para extender este.
	 * @returns {Array} - El array extendido.
	 */
	static Extend(enums*) {
		for enum in enums {
			if !HasMethod(enum, "__Enum")
				throw ValueError("Extend: arr must be an iterable")
			for _, v in enum
				this.Push(v)
		}
		return this
	}


	;;MARK:*
	;? Section: Sorting Algorithms

	/**
	 * Ordena un array, opcionalmente por claves de objeto.
	 * @param {String|Function} [optionsOrCallback="N"] - Una función de callback, o una de las siguientes opciones:
	 * 
	 *     N => el array se considera que consiste solo en valores numéricos. Esta es la opción por defecto.
	 *     C, C1 o COn => ordenación sensible a mayúsculas y minúsculas de cadenas.
	 *     C0 o COff => ordenación insensible a mayúsculas y minúsculas de cadenas.
	 * 
	 *     La función de callback debe aceptar dos parámetros elem1 y elem2 y retornar un entero:
	 *     Retornar entero < 0 si elem1 es menor que elem2.
	 *     Retornar 0 si elem1 es igual a elem2.
	 *     Retornar > 0 si elem1 es mayor que elem2.
	 * @param {String} [key] - Si tienes un array de objetos, especifica aquí la clave por la que se ordenarán los contenidos del objeto.
	 * @returns {Array} - El array ordenado.
	 * @throws {ValueError} - Arroja un error si no se proporcionan opciones válidas.
	 */
	static Sort(optionsOrCallback := "N", key?) {
		static sizeofFieldType := 16 ; Igual en 32 bits y 64 bits
		if HasMethod(optionsOrCallback)
			pCallback := CallbackCreate(CustomCompare.Bind(optionsOrCallback), "F Cdecl", 2), optionsOrCallback := ""
		else {
			if InStr(optionsOrCallback, "N")
				pCallback := CallbackCreate(IsSet(key) ? NumericCompareKey.Bind(key) : NumericCompare, "F CDecl", 2)
			if RegExMatch(optionsOrCallback, "i)C(?!0)|C1|COn")
				pCallback := CallbackCreate(IsSet(key) ? StringCompareKey.Bind(key, , True) : StringCompare.Bind(, , True), "F CDecl", 2)
			if RegExMatch(optionsOrCallback, "i)C0|COff")
				pCallback := CallbackCreate(IsSet(key) ? StringCompareKey.Bind(key) : StringCompare, "F CDecl", 2)
			if InStr(optionsOrCallback, "Random")
				pCallback := CallbackCreate(RandomCompare, "F CDecl", 2)
			if !IsSet(pCallback)
				throw ValueError("No valid options provided!", -1)
		}
		mFields := NumGet(ObjPtr(this) + (8 + (VerCompare(A_AhkVersion, "<2.1-") > 0 ? 3 : 5) * A_PtrSize), "Ptr") ; en v2.0: 0 es VTable. 2 es mBase, 3 es mFields, 4 es FlatVector, 5 es mLength y 6 es mCapacity
		DllCall("msvcrt.dll\qsort", "Ptr", mFields, "UInt", this.Length, "UInt", sizeofFieldType, "Ptr", pCallback, "Cdecl")
		CallbackFree(pCallback)
		if RegExMatch(optionsOrCallback, "i)R(?!a)")
			this.Reverse()
		if InStr(optionsOrCallback, "U")
			this := this.Unique()
		return this

		CustomCompare(compareFunc, pFieldType1, pFieldType2) => (ValueFromFieldType(pFieldType1, &fieldValue1), ValueFromFieldType(pFieldType2, &fieldValue2), compareFunc(fieldValue1, fieldValue2))
		NumericCompare(pFieldType1, pFieldType2) => (ValueFromFieldType(pFieldType1, &fieldValue1), ValueFromFieldType(pFieldType2, &fieldValue2), (fieldValue1 > fieldValue2) - (fieldValue1 < fieldValue2))
		NumericCompareKey(key, pFieldType1, pFieldType2) => (ValueFromFieldType(pFieldType1, &fieldValue1), ValueFromFieldType(pFieldType2, &fieldValue2), (f1 := fieldValue1.HasProp("__Item") ? fieldValue1[key] : fieldValue1.%key%), (f2 := fieldValue2.HasProp("__Item") ? fieldValue2[key] : fieldValue2.%key%), (f1 > f2) - (f1 < f2))
		StringCompare(pFieldType1, pFieldType2, casesense := False) => (ValueFromFieldType(pFieldType1, &fieldValue1), ValueFromFieldType(pFieldType2, &fieldValue2), StrCompare(fieldValue1 "", fieldValue2 "", casesense))
		StringCompareKey(key, pFieldType1, pFieldType2, casesense := False) => (ValueFromFieldType(pFieldType1, &fieldValue1), ValueFromFieldType(pFieldType2, &fieldValue2), StrCompare(fieldValue1.%key% "", fieldValue2.%key% "", casesense))
		RandomCompare(pFieldType1, pFieldType2) => (Random(0, 1) ? 1 : -1)

		ValueFromFieldType(pFieldType, &fieldValue?) {
			static SYM_STRING := 0, PURE_INTEGER := 1, PURE_FLOAT := 2, SYM_MISSING := 3, SYM_OBJECT := 5
			switch SymbolType := NumGet(pFieldType + 8, "Int") {
				case PURE_INTEGER: fieldValue := NumGet(pFieldType, "Int64")
				case PURE_FLOAT: fieldValue := NumGet(pFieldType, "Double")
				case SYM_STRING: fieldValue := StrGet(NumGet(pFieldType, "Ptr") + 2 * A_PtrSize)
				case SYM_OBJECT: fieldValue := ObjFromPtrAddRef(NumGet(pFieldType, "Ptr"))
				case SYM_MISSING: return
			}
		}
	}
}


;todo---MARK: Class ArrayUtiles

/**
 * Clase que proporciona métodos utilitarios para la manipulación de arrays.
 * 
 * @class ArrayUtiles
 */
class ArrayUtiles {


	;;MARK:#
	;^----------------Static Methods----------------^;


	;
	;
	;


	;;MARK:*
	;? Section: Basic Operations

	/**
	 * Combina múltiples arrays en uno solo.
	 * @param {...Array} arrays - Uno o más arrays a combinar.
	 * @returns {_Array} - Un nuevo array que contiene todos los elementos de los arrays proporcionados.
	 */
	static Combine(arrays*) {
		combinedArray := []
		for arr in arrays {
			for item in arr {
				combinedArray.Push(item)
			}
		}
		return combinedArray
	}


	;;MARK:*
	;? Section: Array Generation

	/**
	 * Genera un array con números aleatorios.
	 * @param {Number} indexes - La cantidad de elementos del array.
	 * @param {Number} [variation=7] - El rango de variación para los números aleatorios.
	 * @returns {_Array} - El array generado con números aleatorios.
	 */
	static GenerateRandom(indexes, variation := 7) {
		arrayObj := []
		Loop indexes {
			arrayObj.Push(Random(1, indexes * variation))
		}
		return arrayObj
	}

	/**
	 * Genera un array con números en orden ascendente.
	 * @param {Number} indexes - La cantidad de elementos del array.
	 * @returns {_Array} - El array generado con números en orden ascendente.
	 */
	static GenerateRising(indexes) {
		arrayObj := []
		i := 1
		Loop indexes {
			arrayObj.Push(i)
			i++
		}
		return arrayObj
	}

	/**
	 * Genera un array con números en orden ascendente y luego barajado.
	 * @param {Number} indexes - La cantidad de elementos del array.
	 * @returns {_Array} - El array generado y barajado.
	 */
	static GenerateShuffled(indexes) {
		risingArray := this.GenerateRising(indexes)
		shuffledArray := risingArray.Shuffle()
		return shuffledArray
	}
}


; ;todo---MARK: Examples


; ;
; ;
; ;


; ;======================================
; ;;MARK:*
; ;? Section: Basic Operations
; ;======================================

; /**
;  * Ejemplo de uso de la clase _Array con métodos personalizados
;  */
; myArray := [1, 2, 3, 2, 4, 1]

; /**
;  * Combinar elementos en una cadena utilizando un delimitador
;  * @method _Array.Join
;  */
; MsgBox("Method: Join`nResult: " myArray.Join(" -> "), "Basic Operations")

; /**
;  * Verificar si el array contiene un valor
;  * @method _Array.HasValue
;  */
; MsgBox("Method: HasValue`nContains 2: " myArray.HasValue(2), "Basic Operations") ;; True
; MsgBox("Method: HasValue`nContains 5: " myArray.HasValue(5), "Basic Operations") ;; False

; /**
;  * Dividir el array
;  * @method _Array.Slice
;  */
; slicedArray := [1, 2, 3, 4].Slice(1, 3)
; MsgBox("Method: Slice`nResult: " slicedArray.Join(), "Basic Operations")

; /**
;  * Intercambiar dos elementos del array
;  * @method _Array.Swap
;  */
; swappedArray := [1, 2, 3, 4].Swap(1, 3)
; MsgBox("Method: Swap`nResult: " swappedArray.Join(), "Basic Operations")

; /**
;  * Aplicar una función a cada elemento del array
;  * @method _Array.Map
;  */
; mappedArray := myArray.Map((n) => "( " n " )")
; MsgBox("Method: Map`nResult: " mappedArray.Join(), "Basic Operations")

; /**
;  * Aplicar una función a cada elemento del array sin modificarlo
;  * @method _Array.ForEach
;  */
; myArray.ForEach(ForEachCallback)
; ForEachCallback(val, index, arr) {
; 	MsgBox("Array: " arr.Join() "`nValue: " val ", Index: " index, "Basic Operations")
; }

; myArray.ForEach((val, index, arr) => MsgBox("Array: " arr.Join() "`nValue: " val ", Index: " index, "Basic Operations"))


; /**
;  * Filtrar elementos del array
;  * @method _Array.Filter
;  */
; myArray := [-1, -1.1, 0, 1, 1.1]
; filteredArray := myArray.Filter(IsInteger)
; MsgBox("Method: Filter`nResult: " filteredArray.Join(), "Basic Operations")

; filteredArray := myArray.Filter(isGreaterThanZero)
; MsgBox("Method: Filter`nResult: " filteredArray.Join(), "Basic Operations")
; isGreaterThanZero(v) => v > 0

; /**
;  * Reducir el array a un solo valor
;  * @method _Array.Reduce
;  */
; sum := [1, 2, 3, 4, 5].Reduce((a, b) => a + b, 0)
; MsgBox("Method: Reduce`nResult: " sum, "Basic Operations")

; /**
;  * Encontrar el índice de un valor en el array
;  * @method _Array.IndexOf
;  */
; index := [-5, 9, 2, 8, 1].IndexOf(2)
; MsgBox("Method: IndexOf`nResult: " index, "Basic Operations")

; /**
;  * Encontrar el índice del primer valor que cumple con una condición
;  * @method _Array.Find
;  */
; index := [1, 2, 3, 4, 5].Find((v) => (Mod(v, 2) == 0))
; MsgBox("Method: Find`nResult: " index, "Basic Operations")

; /**
;  * Generar un array con elementos únicos
;  * @method _Array.Unique
;  */
; uniqueArray := [1, 1, 2, 2, 3, 3, 4, 4, 5, 5].Unique()
; MsgBox("Method: Unique`nResult: " uniqueArray.Join(), "Basic Operations")


; ;======================================
; ;;MARK:*
; ;? Section: Shuffling Algorithm
; ;======================================

; /**
;  * Barajar el array
;  * @method _Array.Shuffle
;  */
; myArray := ["a", 1, 2, 3, "a"]
; shuffledArray := myArray.Shuffle()
; MsgBox("Method: Shuffle`nResult: " shuffledArray.Join(), "Shuffling Algorithm")

; /**
;  * Invertir el array
;  * @method _Array.Reverse
;  */
; reversedArray := myArray.Reverse()
; MsgBox("Method: Reverse`nResult: " reversedArray.Join(), "Shuffling Algorithm")

; /**
;  * Contar ocurrencias de un valor
;  * @method _Array.Count
;  */
; count := myArray.Count("a")
; MsgBox("Method: Count`nResult: " count, "Shuffling Algorithm")

; /**
;  * Aplanar un array anidado
;  * @method _Array.Flat
;  */
; nestedArray := [1, [2, [3, 4]], 5]
; flatArray := nestedArray.Flat()
; MsgBox("Method: Flat`nResult: " flatArray.Join(), "Shuffling Algorithm")

; /**
;  * Extender un array con el contenido de otro array
;  * @method _Array.Extend
;  */
; extendedArray := myArray.Extend([6, 7], [8, 9])
; MsgBox("Method: Extend`nResult: " extendedArray.Join(), "Shuffling Algorithm")


; ;======================================
; ;;MARK:*
; ;? Section: Sorting Algorithms
; ;======================================

; /**
;  * Ordenar el array utilizando el método Sort
;  * @method _Array.Sort
;  */
; myArray := [4, 2, 7, 1, 3, -1]
; sortedArray := myArray.Sort("N")
; MsgBox("Method: Sort`nResult: " sortedArray.Join(), "Sorting Algorithms")


; ;======================================
; ;;MARK:*
; ;? Section: Array Generation
; ;======================================

; /**
;  * Generar un array aleatorio
;  * @method ArrayUtiles.GenerateRandom
;  */
; randomArray := ArrayUtiles.GenerateRandom(10)
; MsgBox("Method: GenerateRandom`nResult: " randomArray.Join(), "Array Generation")

; /**
;  * Generar un array en orden ascendente
;  * @method ArrayUtiles.GenerateRising
;  */
; risingArray := ArrayUtiles.GenerateRising(10)
; MsgBox("Method: GenerateRising`nResult: " risingArray.Join(), "Array Generation")

; /**
;  * Generar un array en orden ascendente y luego barajado
;  * @method ArrayUtiles.GenerateShuffled
;  */
; shuffledRisingArray := ArrayUtiles.GenerateShuffled(10)
; MsgBox("Method: GenerateShuffled`nResult: " shuffledRisingArray.Join(), "Array Generation")
