;todo---MARK: Class _Map


Map.Prototype.base := _Map

/**
 * Clase personalizada que extiende la funcionalidad del Map nativo de AutoHotkey.
 * Proporciona métodos adicionales para manipular maps.
 * 
 * @class _Map
 * @extends Map
 */
class _Map extends Map {


	;;MARK:#
	;^----------------Extended Methods----------------^;


	;
	;
	;


	;;MARK:*
	;? Section: Basic Operations

	/**
	 * Convierte un mapa en una cadena, uniendo los pares clave-valor con un carácter especificado.
	 * @param {String} [delimiter=", "] - El carácter para separar los pares clave-valor en la cadena.
	 * @returns {String} - La cadena resultante.
	 */
	static Join(delimiter := ", ") {
		str := ""
		for key, value in this {
			str .= key ": " value delimiter
		}
		return SubStr(str, 1, -StrLen(delimiter)) ; Elimina el delimitador final
	}

	/**
	 * De forma predeterminada, puedes establecer la misma clave en un mapa varias veces.
	 * Naturalmente, solo podrás hacer referencia a una de ellas, lo que probablemente no sea el comportamiento deseado.
	 * Esta función arrojará un error si intentas establecer una clave que ya existe en el mapa.
	 * @param {_Map} mapObj - El mapa en el que se establecerá el par clave-valor.
	 * @param {String} key - La clave a establecer en el mapa.
	 * @param {Any} value - El valor a establecer para la clave.
	 */
	static SafeSet(mapObj, key, value) {
		if !mapObj.Has(key) {
			mapObj.Set(key, value)
			return
		}
		throw IndexError("El mapa ya tiene la clave", -1, key)
	}

	/**
	 * Una versión de SafeSet que permite pasar otro objeto mapa para establecer todo en él.
	 * Aún arrojará un error para cada clave que ya exista en el mapa.
	 * @param {_Map} mapObj - El mapa inicial.
	 * @param {_Map} mapToSet - El mapa que se establecerá en el mapa inicial.
	 */
	static SafeSetMap(mapObj, mapToSet) {
		for key, value in mapToSet {
			this.SafeSet(mapObj, key, value)
		}
	}

	/**
	 * Invierte las claves y valores en un mapa.
	 * @param {_Map} mapObj - El mapa a invertir.
	 * @returns {_Map} - El mapa invertido.
	 */
	static Reverse(mapObj) {
		reversedMap := _Map()
		for key, value in mapObj {
			reversedMap.Set(value, key)
		}
		return reversedMap
	}
}


;todo---MARK: Examples


;
;
;


; ;======================================
; ;;MARK:*
; ;? Section: Basic Operations
; ;======================================

; ;; Crear un mapa de ejemplo
; myMap := Map()
; myMap.Set("a", 1)
; myMap.Set("b", 2)

; ;; SafeSet - Añadir un nuevo par clave-valor
; try {
; 	myMap.SafeSet(myMap, "c", 3)
; 	MsgBox("Method: SafeSet`nResult: Success", "Basic Operations")
; } catch IndexError as e {
; 	MsgBox("Method: SafeSet`nError: " e.message, "Basic Operations")
; }

; ;; SafeSet - Intentar añadir una clave existente
; try {
; 	myMap.SafeSet(myMap, "a", 10)
; } catch IndexError as e {
; 	MsgBox("Method: SafeSet`nError: " e.message, "Basic Operations")
; }

; ;; SafeSetMap - Añadir un mapa a otro mapa
; newMap := Map()
; newMap.Set("d", 4)
; newMap.Set("e", 5)
; try {
; 	myMap.SafeSetMap(myMap, newMap)
; 	MsgBox("Method: SafeSetMap`nResult: Success", "Basic Operations")
; } catch IndexError as e {
; 	MsgBox("Method: SafeSetMap`nError: " e.message, "Basic Operations")
; }

; ;; Reverse - Invertir las claves y valores del mapa
; try {
; 	reversedMap := myMap.Reverse(myMap)
; 	MsgBox("Method: Reverse`nResult: " reversedMap.Join(), "Basic Operations")
; } catch Error as e {
; 	MsgBox("Method: Reverse`nError: " e.message, "Basic Operations")
; }
