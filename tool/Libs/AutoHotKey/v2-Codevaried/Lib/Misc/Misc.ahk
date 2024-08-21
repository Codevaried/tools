/**
 * @file Misc.ahk
 * ! @version 0.5 (21.08.24) (*MOD*)
 * @created 26.08.22
 * @author Descolada (https://www.autohotkey.com/boards/viewtopic.php?f=83&t=107759)
 * @description
 * Esta biblioteca proporciona diversas funciones de utilidad para manejar iterables, intercambiar valores,
 * imprimir valores formateados, trabajar con expresiones regulares, obtener información de ventanas y posiciones de pantalla,
 * y verificar intersecciones de rectángulos.
 * 
 * Funciones incluidas:
 * - Range: Devuelve un iterable para contar desde un número inicial hasta un número final con un paso opcional.
 * - Swap: Intercambia los valores de dos variables.
 * - Print: Imprime el valor formateado de una variable, con soporte para personalizar la función de salida.
 * - RegExMatchAll: Devuelve todos los resultados de RegExMatch en un array.
 * - WindowFromPoint: Devuelve el ID de la ventana en las coordenadas de pantalla X e Y.
 * - ConvertWinPos: Convierte coordenadas entre pantalla, ventana y cliente.
 * - WinGetInfo: Obtiene información sobre una ventana.
 * - GetCaretPos: Obtiene la posición del cursor.
 * - IntersectRect: Verifica si dos rectángulos se intersectan y devuelve el rectángulo de la intersección.
 * 
 * @credit
 * * Coco y Descolada - Agradecimientos especiales por la creación de esta magnífica librería y otras contribuciones.
 * 
 * @note
 * * Esta es una versión modificada de la librería original. La versión original puede encontrarse en el repositorio oficial de Descolada.
 */

/**
 * Devuelve una secuencia de números, comenzando desde 1 por defecto,
 * e incrementa por el paso 1 (por defecto),
 * y se detiene en un número final especificado.
 * Puede convertirse en un array con el método ToArray().
 * @param start El número con el que comenzar, o si 'end' se omite, entonces el número con el que finalizar.
 * @param end El número con el que finalizar.
 * @param step Opcional: un número que especifica la incrementación. Por defecto es 1.
 * @returns {Iterable}
 * @example
 * for v in Range(5)
 *     Print(v) ; Imprime "1 2 3 4 5"
 */
class Range {

	__New(start, end?, step := 1) {
		if !step
			throw TypeError("Parámetro 'step' inválido")
		if !IsSet(end)
			end := start, start := 1
		if (end < start) && (step > 0)
			step := -step
		this.start := start, this.end := end, this.step := step
	}

	__Enum(varCount) {
		start := this.start - this.step, end := this.end, step := this.step, counter := 0
		EnumElements(&element) {
			start := start + step
			if ((step > 0) && (start > end)) || ((step < 0) && (start < end))
				return false
			element := start
			return true
		}
		EnumIndexAndElements(&index, &element) {
			start := start + step
			if ((step > 0) && (start > end)) || ((step < 0) && (start < end))
				return false
			index := ++counter
			element := start
			return true
		}
		return (varCount = 1) ? EnumElements : EnumIndexAndElements
	}

	/**
	 * Convierte el iterable en un array.
	 * @returns {Array}
	 * @example
	 * Range(3).ToArray() ; devuelve [1, 2, 3]
	 */
	ToArray() {
		r := []
		for v in this
			r.Push(v)
		return r
	}
}


/**
 * Intercambia los valores de dos variables.
 * @param a Primera variable.
 * @param b Segunda variable.
 */
Swap(&a, &b) {
	temp := a
	a := b
	b := temp
}


/**
 * Imprime el valor formateado de una variable (número, cadena, objeto).
 * Si no se proporciona ningún valor, devuelve la configuración actual de la función de salida.
 * 
 * @param {*} [value] - Opcional: la variable a imprimir. 
 *     Si el valor es un objeto o clase que tiene un método ToString(), se imprimirá el resultado de ese método.
 * @param {String} [title] - Opcional: el título que se mostrará en la salida. 
 *     Si se omite (no se establece con `IsSet`), se capturará el número de línea desde donde se llama a `Print`.
 *     Si `title` es una cadena vacía (`""`), no se mostrará ningún título.
 * @param {Function} [func=OutputDebug] - Opcional: la función de impresión a usar. 
 *     Por defecto es `OutputDebug`. Si no se proporciona una función, se usará la función almacenada en `p`.
 * 
 * @returns {String|Array} - Devuelve el valor formateado con el título, o un array con la función actual si no se proporciona `value`.
 * 
 * @note
 * Si `title` no se proporciona (unset), la función capturará automáticamente el número de línea desde donde se llama.
 * Si `title` es una cadena vacía, el título no se mostrará en la salida.
 */
Print(value?, title?, func := OutputDebug) {
	static p := OutputDebug

	;; Actualizar la función de salida si se proporciona una nueva.
	p := IsSet(func) ? func : p

	;; Capturar el número de línea si title no se proporciona (unset).
	if !IsSet(title) {
		try {
			throw ValueError("Capturing line number", -1)
		} catch ValueError as err {
			callerLine := err.Line
			SplitPath(err.File, &f)
		}
		title := f ":" callerLine
	}

	;; Formatear el valor y la salida.
	if IsSet(value) {
		val := IsObject(value) ? ToString(value) : value
		output := val

		;; Si el título es una cadena vacía, no mostrar el título.
		if (title = "") {
			HasMethod(p) ? p(output) : output
		} else if (p = MsgBox)
			p(output, title)
		else {
			if (title != "null")
				HasMethod(p) ? p("{" title "} " output) : "{" title "} " output
		}
		return output
	}

	;; Devolver la configuración actual si no se proporciona un valor.
	return [p]
}


/**
 * Convierte un valor (número, array, objeto) en una cadena.
 * Dejar todos los parámetros vacíos devolverá la función actual y el carácter de nueva línea en un Array: [func, newline].
 * @param {*} [val] - Opcional: el valor a convertir.
 * @returns {String}
 */
ToString(val?) {
	if (!IsSet(val))
		return "unset"
	valType := Type(val)
	switch valType, 0 {
		case "String":
			return "'" val "'"
		case "Integer", "Float":
			return val
		default:
			self := "", iter := "", out := ""
			try self := ToString(val.ToString()) ;; si el objeto tiene ToString disponible, imprimirlo
			if (valType != "Array") { ;; enumerar objeto con pares clave y valor, excepto para array
				try {
					enum := val.__Enum(2)
					while (enum.Call(&val1, &val2))
						iter .= ToString(val1) ":" ToString(val2?) ", "
				}
			}
			if !IsSet(enum) { ;; si enumerar con clave y valor falló, intentar de nuevo solo con el valor
				try {
					enum := val.__Enum(1)
					while (enum.Call(&enumVal))
						iter .= ToString(enumVal?) ", "
				}
			}
			if (!IsSet(enum) && (valType = "Object") && !self) { ;; si todo falla, enumerar propiedades del objeto
				for k, v in val.OwnProps()
					iter .= SubStr(ToString(k), 2, -1) ":" ToString(v?) ", "
			}
			iter := SubStr(iter, 1, StrLen(iter) - 2)
			if (!self && !iter && !((valType = "Array" && val.Length = 0) || (valType = "Map" && val.Count = 0) || (valType = "Object" && ObjOwnPropCount(val) = 0)))
				return valType ;; si no hay información adicional disponible, solo imprimir el tipo
			else if (self && iter)
				out .= "value:" self ", iter:[" iter "]"
			else
				out .= self iter
			return (valType = "Object") ? "{" out "}" : (valType = "Array") ? "[" out "]" : valType "(" out ")"
	}
}


/**
 * Devuelve todos los resultados de RegExMatch en un array: [RegExMatchInfo1, RegExMatchInfo2, ...].
 * @param {String} haystack - La cadena cuyo contenido se busca.
 * @param {String} needleRegEx - El patrón RegEx a buscar.
 * @param {Number} [startingPosition=1] - Si StartingPos se omite, por defecto es 1 (el inicio de haystack).
 * @returns {Array}
 */
RegExMatchAll(haystack, needleRegEx, startingPosition := 1) {
	out := [], end := StrLen(haystack) + 1
	While startingPosition < end && RegExMatch(haystack, needleRegEx, &outputVar, startingPosition)
		out.Push(outputVar), startingPosition := outputVar.Pos + (outputVar.Len || 1)
	return out
}


/**
 * Devuelve el ID de la ventana en las coordenadas de pantalla X e Y.
 * @param {Number} X - Coordenada X de la pantalla del punto.
 * @param {Number} Y - Coordenada Y de la pantalla del punto.
 * @returns {Number} - El ID de la ventana.
 */
WindowFromPoint(X, Y) { ; por SKAN y Linear Spoon
	return DllCall("GetAncestor", "UInt", DllCall("user32.dll\WindowFromPoint", "Int64", Y << 32 | X), "UInt", 2)
}


/**
 * Convierte coordenadas entre pantalla, ventana y cliente.
 * @param {Number} X - Coordenada X a convertir.
 * @param {Number} Y - Coordenada Y a convertir.
 * @param {Number} outX - Variable donde almacenar la coordenada X convertida.
 * @param {Number} outY - Variable donde almacenar la coordenada Y convertida.
 * @param {String} [relativeFrom=A_CoordModeMouse] - CoordMode de donde convertir. Por defecto es A_CoordModeMouse.
 * @param {String} [relativeTo=screen] - CoordMode a donde convertir. Por defecto es pantalla.
 * @param {String} [winTitle] - Un título de ventana u otro criterio que identifica la ventana objetivo.
 * @param {String} [winText] - Si está presente, este parámetro debe ser una subcadena de un solo elemento de texto de la ventana objetivo.
 * @param {String} [excludeTitle] - Las ventanas cuyos títulos incluyan este valor no serán consideradas.
 * @param {String} [excludeText] - Las ventanas cuyo texto incluyan este valor no serán consideradas.
 */
ConvertWinPos(X, Y, &outX, &outY, relativeFrom := "", relativeTo := "screen", winTitle?, winText?, excludeTitle?, excludeText?) {
	relativeFrom := (relativeFrom == "") ? A_CoordModeMouse : relativeFrom
	if (relativeFrom = relativeTo) {
		outX := X, outY := Y
		return
	}
	hWnd := WinExist(winTitle?, winText?, excludeTitle?, excludeText?)

	switch relativeFrom, 0 {
		case "screen", "s":
			if (relativeTo = "window" || relativeTo = "w") {
				DllCall("user32\GetWindowRect", "Int", hWnd, "Ptr", RECT := Buffer(16))
				outX := X - NumGet(RECT, 0, "Int"), outY := Y - NumGet(RECT, 4, "Int")
			} else {
				; de pantalla a cliente
				pt := Buffer(8), NumPut("int", X, pt), NumPut("int", Y, pt, 4)
				DllCall("ScreenToClient", "Int", hWnd, "Ptr", pt)
				outX := NumGet(pt, 0, "int"), outY := NumGet(pt, 4, "int")
			}
		case "window", "w":
			; de ventana a pantalla
			WinGetPos(&outX, &outY, , , hWnd)
			outX += X, outY += Y
			if (relativeTo = "client" || relativeTo = "c") {
				; de pantalla a cliente
				pt := Buffer(8), NumPut("int", outX, pt), NumPut("int", outY, pt, 4)
				DllCall("ScreenToClient", "Int", hWnd, "Ptr", pt)
				outX := NumGet(pt, 0, "int"), outY := NumGet(pt, 4, "int")
			}
		case "client", "c":
			; de cliente a pantalla
			pt := Buffer(8), NumPut("int", X, pt), NumPut("int", Y, pt, 4)
			DllCall("ClientToScreen", "Int", hWnd, "Ptr", pt)
			outX := NumGet(pt, 0, "int"), outY := NumGet(pt, 4, "int")
			if (relativeTo = "window" || relativeTo = "w") { ; de pantalla a ventana
				DllCall("user32\GetWindowRect", "Int", hWnd, "Ptr", RECT := Buffer(16))
				outX -= NumGet(RECT, 0, "Int"), outY -= NumGet(RECT, 4, "Int")
			}
	}
}


/**
 * Obtiene información sobre una ventana (título, nombre del proceso, ubicación, etc.).
 * @param {String} [WinTitle=""] - Igual que AHK WinTitle.
 * @param {Number} [Verbose=1] - Qué tan detallada debe ser la salida (por defecto es 1):
 *  0: Devuelve el título de la ventana, hWnd, clase, nombre del proceso, PID, ruta del proceso, posición en pantalla, información de min-max, estilos y ex-estilos.
 *  1: Además devuelve TransColor, nivel de transparencia, texto (tanto oculto como no), texto de la barra de estado.
 *  2: Además devuelve nombres ClassNN para todos los controles.
 * @param {String} [WinText=""] - Igual que AHK WinText.
 * @param {String} [ExcludeTitle=""] - Igual que AHK ExcludeTitle.
 * @param {String} [ExcludeText=""] - Igual que AHK ExcludeText.
 * @param {String} [Separator="`n"] - Carácter(es) de salto de línea.
 * @returns {String} - La información como una cadena.
 * @example MsgBox(WinGetInfo("ahk_exe notepad.exe", 2))
 */
WinGetInfo(WinTitle := "", Verbose := 1, WinText := "", ExcludeTitle := "", ExcludeText := "", Separator := "`n") {
	if !(hWnd := WinExist(WinTitle, WinText, ExcludeTitle, ExcludeText))
		throw TargetError("¡Ventana objetivo no encontrada!", -1)
	out := 'Title: '
	try out .= '"' WinGetTitle(hWnd) '"' Separator
	catch
		out .= "#ERROR" Separator
	out .= 'ahk_id ' hWnd Separator
	out .= 'ahk_class '
	try out .= WinGetClass(hWnd) Separator
	catch
		out .= "#ERROR" Separator
	out .= 'ahk_exe '
	try out .= WinGetProcessName(hWnd) Separator
	catch
		out .= "#ERROR" Separator
	out .= 'ahk_pid '
	try out .= WinGetPID(hWnd) Separator
	catch
		out .= "#ERROR" Separator
	out .= 'ProcessPath: '
	try out .= '"' WinGetProcessPath(hWnd) '"' Separator
	catch
		out .= "#ERROR" Separator
	out .= 'Screen position: '
	try {
		WinGetPos(&X, &Y, &W, &H, hWnd)
		out .= "x: " X " y: " Y " w: " W " h: " H Separator
	} catch
		out .= "#ERROR" Separator
	out .= 'MinMax: '
	try out .= ((minmax := WinGetMinMax(hWnd)) = 1 ? "maximized" : minmax = -1 ? "minimized" : "normal") Separator
	catch
		out .= "#ERROR" Separator

	static Styles := Map("WS_OVERLAPPED", 0x00000000, "WS_POPUP", 0x80000000, "WS_CHILD", 0x40000000, "WS_MINIMIZE", 0x20000000, "WS_VISIBLE", 0x10000000, "WS_DISABLED", 0x08000000, "WS_CLIPSIBLINGS", 0x04000000, "WS_CLIPCHILDREN", 0x02000000, "WS_MAXIMIZE", 0x01000000, "WS_CAPTION", 0x00C00000, "WS_BORDER", 0x00800000, "WS_DLGFRAME", 0x00400000, "WS_VSCROLL", 0x00200000, "WS_HSCROLL", 0x00100000, "WS_SYSMENU", 0x00080000, "WS_THICKFRAME", 0x00040000, "WS_GROUP", 0x00020000, "WS_TABSTOP", 0x00010000, "WS_MINIMIZEBOX", 0x00020000, "WS_MAXIMIZEBOX", 0x00010000, "WS_TILED", 0x00000000, "WS_ICONIC", 0x20000000, "WS_SIZEBOX", 0x00040000, "WS_OVERLAPPEDWINDOW", 0x00CF0000, "WS_POPUPWINDOW", 0x80880000, "WS_CHILDWINDOW", 0x40000000, "WS_TILEDWINDOW", 0x00CF0000, "WS_ACTIVECAPTION", 0x00000001, "WS_GT", 0x00030000)
		, ExStyles := Map("WS_EX_DLGMODALFRAME", 0x00000001, "WS_EX_NOPARENTNOTIFY", 0x00000004, "WS_EX_TOPMOST", 0x00000008, "WS_EX_ACCEPTFILES", 0x00000010, "WS_EX_TRANSPARENT", 0x00000020, "WS_EX_MDICHILD", 0x00000040, "WS_EX_TOOLWINDOW", 0x00000080, "WS_EX_WINDOWEDGE", 0x00000100, "WS_EX_CLIENTEDGE", 0x00000200, "WS_EX_CONTEXTHELP", 0x00000400, "WS_EX_RIGHT", 0x00001000, "WS_EX_LEFT", 0x00000000, "WS_EX_RTLREADING", 0x00002000, "WS_EX_LTRREADING", 0x00000000, "WS_EX_LEFTSCROLLBAR", 0x00004000, "WS_EX_CONTROLPARENT", 0x00010000, "WS_EX_STATICEDGE", 0x00020000, "WS_EX_APPWINDOW", 0x00040000, "WS_EX_OVERLAPPEDWINDOW", 0x00000300, "WS_EX_PALETTEWINDOW", 0x00000188, "WS_EX_LAYERED", 0x00080000, "WS_EX_NOINHERITLAYOUT", 0x00100000, "WS_EX_NOREDIRECTIONBITMAP", 0x00200000, "WS_EX_LAYOUTRTL", 0x00400000, "WS_EX_COMPOSITED", 0x02000000, "WS_EX_NOACTIVATE", 0x08000000)
	out .= 'Style: '
	try {
		out .= (style := WinGetStyle(hWnd)) " ("
		for k, v in Styles {
			if v && style & v {
				out .= k " | "
				style &= ~v
			}
		}
		out := RTrim(out, " |")
		if style
			out .= (SubStr(out, -1, 1) = "(" ? "" : ", ") "Enum desconocido: " style
		out .= ")" Separator
	} catch
		out .= "#ERROR" Separator

	out .= 'ExStyle: '
	try {
		out .= (style := WinGetExStyle(hWnd)) " ("
		for k, v in ExStyles {
			if v && style & v {
				out .= k " | "
				style &= ~v
			}
		}
		out := RTrim(out, " |")
		if style
			out .= (SubStr(out, -1, 1) = "(" ? "" : ", ") "Enum desconocido: " style
		out .= ")" Separator
	} catch
		out .= "#ERROR" Separator

	if Verbose {
		out .= 'TransColor: '
		try out .= WinGetTransColor(hWnd) Separator
		catch
			out .= "#ERROR" Separator
		out .= 'Transparent: '
		try out .= WinGetTransparent(hWnd) Separator
		catch
			out .= "#ERROR" Separator

		PrevDHW := DetectHiddenText(0)
		out .= 'Text (DetectHiddenText Off): '
		try out .= '"' WinGetText(hWnd) '"' Separator
		catch
			out .= "#ERROR" Separator
		DetectHiddenText(1)
		out .= 'Text (DetectHiddenText On): '
		try out .= '"' WinGetText(hWnd) '"' Separator
		catch
			out .= "#ERROR" Separator
		DetectHiddenText(PrevDHW)

		out .= 'StatusBar Text: '
		try out .= '"' StatusBarGetText(1, hWnd) '"' Separator
		catch
			out .= "#ERROR" Separator
	}
	if Verbose > 1 {
		out .= 'Controls (ClassNN): ' Separator
		try {
			for ctrl in WinGetControls(hWnd)
				out .= '`t' ctrl Separator
		} catch
			out .= "#ERROR" Separator
	}
	return SubStr(out, 1, -StrLen(Separator))
}


/**
 * Obtiene la posición del cursor con UIA, Acc o CaretGetPos.
 * Crédito: plankoe (https://www.reddit.com/r/AutoHotkey/comments/ysuawq/get_the_caret_location_in_any_program/)
 * @param {Number} X - Valor establecido a la coordenada X de la pantalla del cursor.
 * @param {Number} Y - Valor establecido a la coordenada Y de la pantalla del cursor.
 * @param {Number} W - Valor establecido al ancho del cursor.
 * @param {Number} H - Valor establecido a la altura del cursor.
 */
GetCaretPos(&X?, &Y?, &W?, &H?) {
	/*
	    Esta implementación prefiere CaretGetPos > Acc > UIA. Esto se debe principalmente a las diferencias de velocidad
	    entre los métodos y estadísticamente parece más probable que el método UIA se requiera menos (las aplicaciones Chromium también soportan Acc).
	*/
	; Cursor por defecto
	savedCaret := A_CoordModeCaret
	CoordMode "Caret", "Screen"
	CaretGetPos(&X, &Y)
	CoordMode "Caret", savedCaret
	if IsInteger(X) && (X | Y) != 0 {
		W := 4, H := 20
		return
	}

	; Cursor Acc
	static _ := DllCall("LoadLibrary", "Str", "oleacc", "Ptr")
	try {
		idObject := 0xFFFFFFF8 ; OBJID_CARET
		if DllCall("oleacc\AccessibleObjectFromWindow", "ptr", WinExist("A"), "uint", idObject &= 0xFFFFFFFF
			, "ptr", -16 + NumPut("int64", idObject == 0xFFFFFFF0 ? 0x46000000000000C0 : 0x719B3800AA000C81, NumPut("int64", idObject == 0xFFFFFFF0 ? 0x0000000000020400 : 0x11CF3C3D618736E0, IID := Buffer(16)))
			, "ptr*", oAcc := ComValue(9, 0)) = 0 {
			x := Buffer(4), y := Buffer(4), w := Buffer(4), h := Buffer(4)
			oAcc.accLocation(ComValue(0x4003, x.ptr, 1), ComValue(0x4003, y.ptr, 1), ComValue(0x4003, w.ptr, 1), ComValue(0x4003, h.ptr, 1), 0)
			X := NumGet(x, 0, "int"), Y := NumGet(y, 0, "int"), W := NumGet(w, 0, "int"), H := NumGet(h, 0, "int")
			if (X | Y) != 0
				return
		}
	}

	; Cursor UIA
	static IUIA := ComObject("{e22ad333-b25f-460c-83d0-0581107395c9}", "{34723aff-0c9d-49d0-9896-7ab52df8cd8a}")
	try {
		ComCall(8, IUIA, "ptr*", &FocusedEl := 0) ; GetFocusedElement
		/*
		    La implementación actual utiliza solo TextPattern GetSelections y no TextPattern2 GetCaretRange.
		    Esto se debe a que TextPattern2 es menos frecuentemente soportado, o a veces informa estar implementado
		    pero en realidad no lo está. El único inconveniente de usar GetSelections es que cuando el texto
		    está seleccionado, la posición del cursor es ambigua. Sin embargo, en esos casos,
		    lo más probable es que no importe mucho si el cursor está en el principio o al final de la selección.
		
		    Si se necesita GetCaretRange, el siguiente código lo implementa:
		    ComCall(16, FocusedEl, "int", 10024, "ptr*", &patternObject:=0), ObjRelease(FocusedEl) ; GetCurrentPattern. TextPattern2 = 10024
		    if patternObject {
		        ComCall(10, patternObject, "int*", &IsActive:=1, "ptr*", &caretRange:=0), ObjRelease(patternObject) ; GetCaretRange
		        ComCall(10, caretRange, "ptr*", &boundingRects:=0), ObjRelease(caretRange) ; GetBoundingRectangles
		        if (Rect := ComValue(0x2005, boundingRects)).MaxIndex() = 3 { ; VT_ARRAY | VT_R8
		            X:=Round(Rect[0]), Y:=Round(Rect[1]), W:=Round(Rect[2]), H:=Round(Rect[3])
		            return
		        }
		    }
		*/
		ComCall(16, FocusedEl, "int", 10014, "ptr*", &patternObject := 0), ObjRelease(FocusedEl) ; GetCurrentPattern. TextPattern = 10014
		if patternObject {
			ComCall(5, patternObject, "ptr*", &selectionRanges := 0), ObjRelease(patternObject) ; GetSelections
			ComCall(4, selectionRanges, "int", 0, "ptr*", &selectionRange := 0) ; GetElement
			ComCall(10, selectionRange, "ptr*", &boundingRects := 0), ObjRelease(selectionRange), ObjRelease(selectionRanges) ; GetBoundingRectangles
			if (Rect := ComValue(0x2005, boundingRects)).MaxIndex() = 3 { ; VT_ARRAY | VT_R8
				X := Round(Rect[0]), Y := Round(Rect[1]), W := Round(Rect[2]), H := Round(Rect[3])
				return
			}
		}
	}
}


/**
 * Verifica si dos rectángulos se intersectan y si lo hacen, devuelve un objeto que contiene el
 * rectángulo de la intersección: {l:left, t:top, r:right, b:bottom}.
 * Nota 1: El área de superposición debe ser al menos 1 unidad.
 * Nota 2: Un segundo rectángulo que comienza en el borde del primero no cuenta como intersección:
 *     {l:100, t:100, r:200, b:200} no se intersecta con {l:200, t:100, 400, 400}
 * @param {Number} l1 - Coordenada x de la esquina superior izquierda del primer rectángulo.
 * @param {Number} t1 - Coordenada y de la esquina superior izquierda del primer rectángulo.
 * @param {Number} r1 - Coordenada x de la esquina inferior derecha del primer rectángulo.
 * @param {Number} b1 - Coordenada y de la esquina inferior derecha del primer rectángulo.
 * @param {Number} l2 - Coordenada x de la esquina superior izquierda del segundo rectángulo.
 * @param {Number} t2 - Coordenada y de la esquina superior izquierda del segundo rectángulo.
 * @param {Number} r2 - Coordenada x de la esquina inferior derecha del segundo rectángulo.
 * @param {Number} b2 - Coordenada y de la esquina inferior derecha del segundo rectángulo.
 * @returns {Object} - Un objeto que contiene las coordenadas del rectángulo de intersección.
 */
IntersectRect(l1, t1, r1, b1, l2, t2, r2, b2) {
	rect1 := Buffer(16), rect2 := Buffer(16), rectOut := Buffer(16)
	NumPut("int", l1, "int", t1, "int", r1, "int", b1, rect1)
	NumPut("int", l2, "int", t2, "int", r2, "int", b2, rect2)
	if DllCall("user32\IntersectRect", "Ptr", rectOut, "Ptr", rect1, "Ptr", rect2)
		return { l: NumGet(rectOut, 0, "Int"), t: NumGet(rectOut, 4, "Int"), r: NumGet(rectOut, 8, "Int"), b: NumGet(rectOut, 12, "Int") }
}