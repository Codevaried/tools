/**
 * Nombre: String.ahk
 * Versión: 0.15 (05.09.23)
 * Creado: 27.08.22
 * Autor: Descolada
 * Créditos:
 *  - tidbit --- Autor de "String Things - Common String & Array Functions", del cual
 *               copié o basé muchos métodos
 * Contribuyentes: Axlefublr, neogna2
 * Contribuyentes de "String Things": AfterLemon, Bon, Lexikos, MasterFocus, Rseding91, Verdlin
 * 
 * Descripción:
 * Una recopilación de métodos útiles para manejar cadenas de texto. También permite tratar las cadenas como objetos.
 * 
 * Estos métodos no pueden ser usados de forma independiente. Para hacerlo, debe agregar otro argumento
 * 'string' a la función y reemplazar todas las ocurrencias de 'this' con 'string'.
 * 
 * Propiedades:
 * @property {number} String.Length - La longitud de la cadena
 * @property {boolean} String.IsDigit - Verifica si la cadena contiene solo dígitos
 * @property {boolean} String.IsXDigit - Verifica si la cadena contiene solo dígitos hexadecimales
 * @property {boolean} String.IsAlpha - Verifica si la cadena contiene solo caracteres alfabéticos
 * @property {boolean} String.IsUpper - Verifica si la cadena contiene solo caracteres en mayúsculas
 * @property {boolean} String.IsLower - Verifica si la cadena contiene solo caracteres en minúsculas
 * @property {boolean} String.IsAlnum - Verifica si la cadena contiene solo caracteres alfanuméricos
 * @property {boolean} String.IsSpace - Verifica si la cadena contiene solo caracteres de espacio
 * @property {boolean} String.IsTime - Verifica si la cadena tiene un formato de tiempo válido
 * 
 * Métodos:
 * @method String.ToUpper() - Convierte la cadena a mayúsculas
 * @method String.ToLower() - Convierte la cadena a minúsculas
 * @method String.ToTitle() - Convierte la cadena a formato título
 * @method String.Split([Delimiters, OmitChars, MaxParts]) - Divide la cadena en un arreglo
 * @method String.Replace(Needle [, ReplaceText, CaseSense, &OutputVarCount, Limit]) - Reemplaza ocurrencias de una subcadena
 * @method String.Trim([OmitChars]) - Recorta los espacios en blanco u otros caracteres especificados de ambos extremos de la cadena
 * @method String.LTrim([OmitChars]) - Recorta los espacios en blanco u otros caracteres especificados del extremo izquierdo de la cadena
 * @method String.RTrim([OmitChars]) - Recorta los espacios en blanco u otros caracteres especificados del extremo derecho de la cadena
 * @method String.Compare(comparison [, CaseSense]) - Compara dos cadenas
 * @method String.Sort([, Options, Function]) - Ordena la cadena
 * @method String.Format([Values...]) - Formatea la cadena
 * @method String.Find(Needle [, CaseSense, StartingPos, Occurrence]) - Encuentra una subcadena dentro de la cadena
 * @method String.SplitPath() - Divide la cadena en componentes de ruta y devuelve un objeto {FileName, Dir, Ext, NameNoExt, Drive}
 * @method String.RegExMatch(needleRegex, &match?, startingPos?) - Coincide una expresión regular con la cadena
 * @method String.RegExMatchAll(needleRegex, startingPos?) - Coincide todas las ocurrencias de una expresión regular con la cadena
 * @method String.RegExReplace(needle, replacement?, &count?, limit?, startingPos?) - Reemplaza ocurrencias de una expresión regular
 * 
 * Métodos adicionales:
 * @method String[n] - Obtiene el n-ésimo carácter de la cadena
 * @method String[i,j] - Obtiene la subcadena de i a j
 * @method for [index,] char in String - Itera sobre los caracteres en la cadena
 * @method String.Length - Obtiene la longitud de la cadena
 * @method String.Count(searchFor) - Cuenta las ocurrencias de una subcadena
 * @method String.Insert(insert, into [, pos]) - Inserta una subcadena en una posición especificada
 * @method String.Delete(string [, start, length]) - Elimina una subcadena de la cadena
 * @method String.Overwrite(overwrite, into [, pos]) - Sobrescribe una subcadena en una posición especificada
 * @method String.Repeat(count) - Repite la cadena un número especificado de veces
 * @method Delimeter.Concat(words*) - Concatena múltiples cadenas con un delimitador
 * @method String.LineWrap([column:=56, indentChar:=""]) - Ajusta la cadena en líneas de una anchura de columna especificada
 * @method String.WordWrap([column:=56, indentChar:=""]) - Ajusta la cadena en palabras de una anchura de columna especificada
 * @method String.ReadLine(line [, delim:="`n", exclude:="`r"]) - Lee una línea específica de la cadena
 * @method String.DeleteLine(line [, delim:="`n", exclude:="`r"]) - Elimina una línea específica de la cadena
 * @method String.InsertLine(insert, into, line [, delim:="`n", exclude:="`r"]) - Inserta una línea en la cadena
 * @method String.Reverse() - Invierte la cadena
 * @method String.Contains(needle1 [, needle2, needle3...]) - Verifica si la cadena contiene alguna de las subcadenas especificadas
 * @method String.RemoveDuplicates([delim:="`n"]) - Elimina líneas duplicadas de la cadena
 * @method String.LPad(count) - Rellena la cadena con espacios u otros caracteres especificados a la izquierda
 * @method String.RPad(count) - Rellena la cadena con espacios u otros caracteres especificados a la derecha
 * @method String.Center([fill:=" ", symFill:=0, delim:="`n", exclude:="`r", width]) - Centra la cadena dentro de una anchura especificada
 * @method String.Right([fill:=" ", delim:="`n", exclude:="`r"]) - Alinea la cadena a la derecha dentro de una anchura especificada
 */
Class _String {

	/**
	 * Constructor estático que añade los métodos y propiedades de _String al objeto String.
	 * @static
	 */
	static __New() {
		;; Añade los métodos y propiedades de _String al objeto String
		__ObjDefineProp := Object.Prototype.DefineProp
		for __String2_Prop in _String.OwnProps()
			if SubStr(__String2_Prop, 1, 2) != "__"
				__ObjDefineProp(String.Prototype, __String2_Prop, _String.GetOwnPropDesc(__String2_Prop))
		__ObjDefineProp(String.Prototype, "__Item", { get: (args*) => _String.__Item[args*] })
		__ObjDefineProp(String.Prototype, "__Enum", { call: _String.__Enum })
	}

	/**
	 * Getter estático para acceder a un elemento de la cadena.
	 * @param {...*} args Los argumentos para acceder al elemento.
	 * @returns {String} El carácter o subcadena especificada.
	 * @static
	 */
	static __Item[args*] {
		get {
			if args.length = 2
				return SubStr(args[1], args[2], 1)
			else {
				len := StrLen(args[1])
				if args[2] < 0
					args[2] := len + args[2] + 1
				if args[3] < 0
					args[3] := len + args[3] + 1
				if args[3] >= args[2]
					return SubStr(args[1], args[2], args[3] - args[2] + 1)
				else
					return SubStr(args[1], args[3], args[2] - args[3] + 1).Reverse()
			}
		}
	}

	/**
	 * Método estático para enumerar los elementos de la cadena.
	 * @param {number} varCount El número de variables a enumerar.
	 * @returns {Function} Una función para enumerar los elementos o los índices y elementos.
	 * @static
	 */
	static __Enum(varCount) {
		pos := 0, len := StrLen(this)
		EnumElements(&char) {
			char := StrGet(StrPtr(this) + 2 * pos, 1)
			return ++pos <= len
		}

		EnumIndexAndElements(&index, &char) {
			char := StrGet(StrPtr(this) + 2 * pos, 1), index := ++pos
			return pos <= len
		}

		return varCount = 1 ? EnumElements : EnumIndexAndElements
	}


	;; Funciones nativas implementadas como métodos para el objeto String
	static Length => StrLen(this)
	static WLength => (RegExReplace(this, "s).", "", &i), i)
	static ULength => StrLen(RegExReplace(this, "s)((?>\P{M}(\p{M}|\x{200D}))+\P{M})|\X", "_"))
	static IsDigit => IsDigit(this)
	static IsXDigit => IsXDigit(this)
	static IsAlpha => IsAlpha(this)
	static IsUpper => IsUpper(this)
	static IsLower => IsLower(this)
	static IsAlnum => IsAlnum(this)
	static IsSpace => IsSpace(this)
	static IsTime => IsTime(this)
	static ToUpper() => StrUpper(this)
	static ToLower() => StrLower(this)
	static ToTitle() => StrTitle(this)
	static Split(args*) => StrSplit(this, args*)
	static Replace(args*) => StrReplace(this, args*)
	static Trim(args*) => Trim(this, args*)
	static LTrim(args*) => LTrim(this, args*)
	static RTrim(args*) => RTrim(this, args*)
	static Compare(args*) => StrCompare(this, args*)
	static Sort(args*) => Sort(this, args*)
	static Format(args*) => Format(this, args*)
	static Find(args*) => InStr(this, args*)
	static SplitPath() => (SplitPath(this, &a1, &a2, &a3, &a4, &a5), { FileName: a1, Dir: a2, Ext: a3, NameNoExt: a4, Drive: a5 })

	/**
	 * Devuelve el objeto de coincidencia
	 * @param needleRegex *String* Patrón a coincidir
	 * @param startingPos *Integer* Especifica un número para comenzar a coincidir. Por defecto, comienza desde el inicio de la cadena
	 * @returns {Object}
	 */
	static RegExMatch(needleRegex, &match?, startingPos?) => (RegExMatch(this, needleRegex, &match, startingPos?), match)

	/**
	 * Devuelve todos los resultados de RegExMatch en un arreglo: [RegExMatchInfo1, RegExMatchInfo2, ...]
	 * @param needleRegEx *String* El patrón de expresión regular a buscar
	 * @param startingPosition *Integer* Si no se especifica StartingPos, comienza desde 1 (el inicio de la cadena)
	 * @returns {Array}
	 */
	static RegExMatchAll(needleRegEx, startingPosition := 1) {
		out := []
		While startingPosition := RegExMatch(this, needleRegEx, &outputVar, startingPosition)
			out.Push(outputVar), startingPosition += outputVar[0] ? StrLen(outputVar[0]) : 1
		return out
	}

	/**
	 * Utiliza regex para realizar un reemplazo, devuelve la cadena modificada
	 * @param needleRegex *String* Patrón a coincidir.
	 * 	Esto también puede ser un arreglo de patrones (y replacement un arreglo correspondiente de valores de reemplazo),
	 * 	en cuyo caso todos los pares serán buscados y reemplazados con el reemplazo correspondiente.
	 * 	replacement debe dejarse vacío, outputVarCount se establecerá en el número total de reemplazos, limit es el máximo
	 * 	número de reemplazos para cada par patrón-reemplazo.
	 * @param replacement *String* Texto para reemplazar la coincidencia
	 * @param outputVarCount *VarRef* Especifica una variable con un `&` antes para asignarle la cantidad de reemplazos realizados
	 * @param limit *Integer* El número máximo de reemplazos que pueden ocurrir. Ilimitado por defecto
	 * @param startingPos *Integer* Especifica un número para comenzar a coincidir. Por defecto, comienza desde el inicio de la cadena
	 * @returns {String} La cadena modificada
	 */
	static RegExReplace(needleRegex, replacement?, &outputVarCount?, limit?, startingPos?) {
		if IsObject(needleRegex) {
			out := this, count := 0
			for i, needle in needleRegex {
				out := RegExReplace(out, needle, IsSet(replacement) ? replacement[i] : unset, &count, limit?, startingPos?)
				if IsSet(outputVarCount)
					outputVarCount += count
			}
			return out
		}
		return RegExReplace(this, needleRegex, replacement?, &outputVarCount, limit?, startingPos?)
	}

	/**
	 * Añadir caracteres al lado izquierdo de la cadena de entrada.
	 * ejemplo: "aaa".LPad("+", 5)
	 * salida: +++++aaa
	 * @param padding Texto que desea agregar
	 * @param count Cuántas veces desea repetir la adición al lado izquierdo
	 * @returns {String}
	 */
	static LPad(padding, count := 1) {
		str := this
		if (count > 0) {
			Loop count
				str := padding str
		}
		return str
	}

	/**
	 * Añadir caracteres al lado derecho de la cadena de entrada.
	 * ejemplo: "aaa".RPad("+", 5)
	 * salida: aaa+++++
	 * @param padding Texto que desea agregar
	 * @param count Cuántas veces desea repetir la adición al lado derecho
	 * @returns {String}
	 */
	static RPad(padding, count := 1) {
		str := this
		if (count > 0) {
			Loop count
				str := str padding
		}
		return str
	}

	/**
	 * Cuenta el número de ocurrencias de needle en la cadena
	 * entrada: "12234".Count("2")
	 * salida: 2
	 * @param needle Texto a buscar
	 * @param caseSensitive Sensible a mayúsculas y minúsculas
	 * @returns {Integer}
	 */
	static Count(needle, caseSensitive := False) {
		StrReplace(this, needle, , caseSensitive, &count)
		return count
	}

	/**
	 * Duplica la cadena 'count' veces.
	 * entrada: "abc".Repeat(3)
	 * salida: "abcabcabc"
	 * @param count *Integer*
	 * @returns {String}
	 */
	static Repeat(count) => StrReplace(Format("{:" count "}", ""), " ", this)

	/**
	 * Invierte la cadena.
	 * @returns {String}
	 */
	static Reverse() {
		DllCall("msvcrt\_wcsrev", "str", str := this, "CDecl str")
		return str
	}


	/**
	 * Invierte la cadena teniendo en cuenta los caracteres Unicode.
	 * @returns {String} La cadena invertida.
	 */
	static WReverse() {
		str := this, out := "", m := ""
		While str && (m := Chr(Ord(str))) && (out := m . out)
			str := SubStr(str, StrLen(m) + 1)
		return out
	}

	/**
	 * Inserta la cadena dentro de 'insert' en la posición 'pos'
	 * entrada: "abc".Insert("d", 2)
	 * salida: "adbc"
	 * @param insert El texto a insertar
	 * @param pos *Integer*
	 * @returns {String}
	 */
	static Insert(insert, pos := 1) {
		Length := StrLen(this)
		((pos > 0)
			? pos2 := pos - 1
				: (pos = 0
					? (pos2 := StrLen(this), Length := 0)
						: pos2 := pos
				)
		)
		output := SubStr(this, 1, pos2) . insert . SubStr(this, pos, Length)
		if (StrLen(output) > StrLen(this) + StrLen(insert))
			((Abs(pos) <= StrLen(this) / 2)
				? (output := SubStr(output, 1, pos2 - 1)
					. SubStr(output, pos + 1, StrLen(this))
				)
					: (output := SubStr(output, 1, pos2 - StrLen(insert) - 2)
						. SubStr(output, pos - StrLen(insert), StrLen(this))
					)
			)
		return output
	}

	/**
	 * Reemplaza parte de la cadena con la cadena en 'overwrite' comenzando desde la posición 'pos'
	 * entrada: "aaabbbccc".Overwrite("zzz", 4)
	 * salida: "aaazzzccc"
	 * @param overwrite Texto a insertar
	 * @param pos La posición donde comenzar a sobrescribir. 0 puede usarse para sobrescribir al final, -1 se desplazará 1 desde el final, y así sucesivamente.
	 * @returns {String}
	 */
	static Overwrite(overwrite, pos := 1) {
		if (Abs(pos) > StrLen(this))
			return ""
		else if (pos > 0)
			return SubStr(this, 1, pos - 1) . overwrite . SubStr(this, pos + StrLen(overwrite))
		else if (pos < 0)
			return SubStr(this, 1, pos) . overwrite . SubStr(this " ", (Abs(pos) > StrLen(overwrite) ? pos + StrLen(overwrite) : 0), Abs(pos + StrLen(overwrite)))
		else if (pos = 0)
			return this . overwrite
	}

	/**
	 * Elimina un rango de caracteres de la cadena especificada.
	 * entrada: "aaabbbccc".Delete(4, 3)
	 * salida: "aaaccc"
	 * @param start La posición donde comenzar a eliminar
	 * @param length Cuántos caracteres eliminar
	 * @returns {String}
	 */
	static Delete(start := 1, length := 1) {
		if (Abs(start) > StrLen(this))
			return ""
		if (start > 0)
			return SubStr(this, 1, start - 1) . SubStr(this, start + length)
		else if (start <= 0)
			return SubStr(this " ", 1, start - 1) SubStr(this " ", ((start < 0) ? start - 1 + length : 0), -1)
	}

	/**
	 * Ajusta la cadena para que cada línea no tenga más de una longitud especificada.
	 * entrada: "Apples are a round fruit, usually red".LineWrap(20, "---")
	 * salida: "Apples are a round f
	 *          ---ruit, usually red"
	 * @param column Especifica una longitud máxima por línea
	 * @param indentChar Elige un carácter para indentar las líneas siguientes
	 * @returns {String}
	 */
	static LineWrap(column := 56, indentChar := "") {
		CharLength := StrLen(indentChar)
			, columnSpan := column - CharLength
			, Ptr := A_PtrSize ? "Ptr" : "UInt"
			, UnicodeModifier := 2
			, VarSetStrCapacity(&out, (finalLength := (StrLen(this) + (Ceil(StrLen(this) / columnSpan) * (column + CharLength + 1)))) * 2)
			, A := StrPtr(out)

		Loop parse, this, "`n", "`r" {
			if ((FieldLength := StrLen(ALoopField := A_LoopField)) > column) {
				DllCall("RtlMoveMemory", "Ptr", A, "ptr", StrPtr(ALoopField), "UInt", column * UnicodeModifier)
					, A += column * UnicodeModifier
					, NumPut("UShort", 10, A)
					, A += UnicodeModifier
					, Pos := column

				While (Pos < FieldLength) {
					if CharLength
						DllCall("RtlMoveMemory", "Ptr", A, "ptr", StrPtr(indentChar), "UInt", CharLength * UnicodeModifier)
							, A += CharLength * UnicodeModifier

					if (Pos + columnSpan > FieldLength)
						DllCall("RtlMoveMemory", "Ptr", A, "ptr", StrPtr(ALoopField) + (Pos * UnicodeModifier), "UInt", (FieldLength - Pos) * UnicodeModifier)
							, A += (FieldLength - Pos) * UnicodeModifier
							, Pos += FieldLength - Pos
					else
						DllCall("RtlMoveMemory", "Ptr", A, "ptr", StrPtr(ALoopField) + (Pos * UnicodeModifier), "UInt", columnSpan * UnicodeModifier)
							, A += columnSpan * UnicodeModifier
							, Pos += columnSpan

					NumPut("UShort", 10, A)
						, A += UnicodeModifier
				}
			} else
				DllCall("RtlMoveMemory", "Ptr", A, "ptr", StrPtr(ALoopField), "UInt", FieldLength * UnicodeModifier)
					, A += FieldLength * UnicodeModifier
					, NumPut("UShort", 10, A)
					, A += UnicodeModifier
		}
		NumPut("UShort", 0, A)
		VarSetStrCapacity(&out, -1)
		return SubStr(out, 1, -1)
	}

	/**
	 * Ajusta la cadena para que cada línea no tenga más de una longitud especificada.
	 * A diferencia de LineWrap(), este método tiene en cuenta las palabras separadas por un espacio.
	 * entrada: "Apples are a round fruit, usually red.".WordWrap(20, "---")
	 * salida: "Apples are a round
	 *          ---fruit, usually
	 *          ---red."
	 * @param column Especifica una longitud máxima por línea
	 * @param indentChar Elige un carácter para indentar las líneas siguientes
	 * @returns {String}
	 */
	static WordWrap(column := 56, indentChar := "") {
		if !IsInteger(column)
			throw TypeError("WordWrap: el argumento 'column' debe ser un entero", -1)
		out := ""
		indentLength := StrLen(indentChar)

		Loop parse, this, "`n", "`r" {
			if (StrLen(A_LoopField) > column) {
				pos := 1
				Loop parse, A_LoopField, " "
					if (pos + (LoopLength := StrLen(A_LoopField)) <= column)
						out .= (A_Index = 1 ? "" : " ") A_LoopField
							, pos += LoopLength + 1
					else
						pos := LoopLength + 1 + indentLength
							, out .= "`n" indentChar A_LoopField

				out .= "`n"
			} else
				out .= A_LoopField "`n"
		}
		return SubStr(out, 1, -1)
	}

	/**
	 * Inserta una línea de texto en el número de línea especificado.
	 * La línea que se especifica se desplaza hacia abajo 1 y su texto se inserta en su
	 * posición. Una "línea" puede ser determinada por el parámetro delimitador. No
	 * necesariamente solo un `r o `n. Pero quizás desee un | como su "línea".
	 * entrada: "aaa|ccc|ddd".InsertLine("bbb", 2, "|")
	 * salida: "aaa|bbb|ccc|ddd"
	 * @param insert Texto que desea insertar
	 * @param line Número de línea en el que desea insertar. Use 0 o negativo para comenzar a insertar desde el final
	 * @param delim El carácter que define una "línea"
	 * @param exclude El texto que desea ignorar al definir una línea
	 * @returns {String}
	 */
	static InsertLine(insert, line, delim := "`n", exclude := "`r") {
		if StrLen(delim) != 1
			throw ValueError("InsertLine: El delimitador solo puede ser un carácter", -1)
		into := this, new := ""
		count := into.Count(delim) + 1

		;; Crear cualquier línea que no exista aún, si la línea es menor que el recuento total de líneas.
		if (line < 0 && Abs(line) > count) {
			Loop Abs(line) - count
				into := delim into
			line := 1
		}
		if (line == 0)
			line := Count + 1
		if (line < 0)
			line := count + line + 1
		;; Crear cualquier línea que no exista aún. De lo contrario, la inserción no funciona.
		if (count < line)
			Loop line - count
				into .= delim

		Loop parse, into, delim, exclude
			new .= ((a_index == line) ? insert . delim . A_LoopField . delim : A_LoopField . delim)

		return SubStr(new, 1, -(line > count ? 2 : 1))
	}

	/**
	 * Elimina una línea de texto en el número de línea especificado.
	 * La línea especificada se elimina y todas las líneas debajo de ella se desplazan hacia arriba.
	 * Una "línea" puede ser determinada por el parámetro delimitador. No necesariamente
	 * solo un `r o `n. Pero quizás desee un | como su "línea".
	 * entrada: "aaa|bbb|777|ccc".DeleteLine(3, "|")
	 * salida: "aaa|bbb|ccc"
	 * @param string Texto del cual desea eliminar la línea
	 * @param line Línea que desea eliminar. Puede usar -1 para la última línea y un negativo para un desplazamiento desde el final. -2 sería la penúltima.
	 * @param delim El carácter que define una "línea"
	 * @param exclude El texto que desea ignorar al definir una línea
	 * @returns {String}
	 */
	static DeleteLine(line, delim := "`n", exclude := "`r") {
		if StrLen(delim) != 1
			throw ValueError("DeleteLine: El delimitador solo puede ser un carácter", -1)
		new := ""
		;; verifica si estamos tratando de eliminar una línea que no existe
		count := this.Count(delim) + 1
		if (abs(line) > Count)
			throw ValueError("DeleteLine: el número de línea no puede ser mayor que el número de líneas", -1)
		if (line < 0)
			line := count + line + 1
		else if (line = 0)
			throw ValueError("DeleteLine: el número de línea no puede ser 0", -1)

		Loop parse, this, delim, exclude {
			if (a_index == line) {
				Continue
			} else
				(new .= A_LoopField . delim)
		}

		return SubStr(new, 1, -1)
	}

	/**
	 * Lee el contenido de la línea especificada en una cadena. Una "línea" puede ser
	 * determinada por el parámetro delimitador. No necesariamente solo un `r o `n.
	 * Pero quizás desee un | como su "línea".
	 * entrada: "aaa|bbb|ccc|ddd|eee|fff".ReadLine(4, "|")
	 * salida: "ddd"
	 * @param line Qué línea leer. "L" = La última línea. "R" = Una línea aleatoria. De lo contrario, especifique un número para obtener esa línea. Puede especificar un número negativo para obtener la línea desde el final. -1 es lo mismo que "L", la última. -2 sería la penúltima, y así sucesivamente.
	 * @param delim El carácter que define una "línea"
	 * @param exclude El texto que desea ignorar al definir una línea
	 * @returns {String}
	 */
	static ReadLine(line, delim := "`n", exclude := "`r") {
		out := "", count := this.Count(delim) + 1

		if (line = "R")
			line := Random(1, count)
		else if (line = "L")
			line := count
		else if abs(line) > Count
			throw ValueError("ReadLine: el número de línea no puede ser mayor que el número de líneas", -1)
		else if (line < 0)
			line := count + line + 1
		else if (line = 0)
			throw ValueError("ReadLine: el número de línea no puede ser 0", -1)

		Loop parse, this, delim, exclude {
			if A_Index = line
				return A_LoopField
		}
		throw Error("ReadLine: algo salió mal, la línea no se encontró", -1)
	}

	/**
	 * Reemplaza todas las ocurrencias consecutivas de 'delim' con solo una ocurrencia.
	 * entrada: "aaa|bbb|||ccc||ddd".RemoveDuplicates("|")
	 * salida: "aaa|bbb|ccc|ddd"
	 * @param delim *String*
	 */
	static RemoveDuplicates(delim := "`n") => RegExReplace(this, "(\Q" delim "\E)+", "$1")

	/**
	 * Verifica si la cadena contiene alguna de las agujas proporcionadas.
	 * entrada: "aaa|bbb|ccc|ddd".Contains("eee", "aaa")
	 * salida: 1 (aunque la cadena no contiene "eee", SÍ contiene "aaa")
	 * @param needles
	 * @returns {Boolean}
	 */
	static Contains(needles*) {
		for needle in needles
			if InStr(this, needle)
				return 1
		return 0
	}

	/**
	 * Centra un bloque de texto al ítem más largo de la cadena.
	 * ejemplo: "aaa`na`naaaaaaaa".Center()
	 * salida: "aaa
	 *           a
	 *       aaaaaaaa"
	 * @param text El texto que desea centrar
	 * @param fill Un solo carácter para usar como relleno para centrar el texto
	 * @param symFill 0: Solo llenar el lado izquierdo. 1: Llenar ambos lados.
	 * @param delim El carácter que define una "línea"
	 * @param exclude El texto que desea ignorar al definir una línea
	 * @param width Puede especificarse para añadir relleno adicional a los lados
	 * @returns {String}
	 */
	static Center(fill := " ", symFill := 0, delim := "`n", exclude := "`r", width?) {
		fill := SubStr(fill, 1, 1), longest := 0, new := ""
		Loop parse, this, delim, exclude
			if (StrLen(A_LoopField) > longest)
				longest := StrLen(A_LoopField)
		if IsSet(width)
			longest := Max(longest, width)
		Loop parse this, delim, exclude
		{
			filled := "", len := StrLen(A_LoopField)
			Loop (longest - len) // 2
				filled .= fill
			new .= filled A_LoopField ((symFill = 1) ? filled (2 * StrLen(filled) + len = longest ? "" : fill) : "") "`n"
		}
		return RTrim(new, "`r`n")
	}

	/**
	 * Alinear un bloque de texto al lado derecho.
	 * entrada: "aaa`na`naaaaaaaa".Right()
	 * salida: "     aaa
	 *                 a
	 *          aaaaaaaa"
	 * @param fill Un solo carácter para usar como relleno para empujar el texto a la derecha
	 * @param delim El carácter que define una "línea"
	 * @param exclude El texto que desea ignorar al definir una línea
	 * @returns {String}
	 */
	static Right(fill := " ", delim := "`n", exclude := "`r") {
		fill := SubStr(fill, 1, 1), longest := 0, new := ""
		Loop parse, this, delim, exclude
			if (StrLen(A_LoopField) > longest)
				longest := StrLen(A_LoopField)
		Loop parse, this, delim, exclude {
			filled := ""
			Loop Abs(longest - StrLen(A_LoopField))
				filled .= fill
			new .= filled A_LoopField "`n"
		}
		return RTrim(new, "`r`n")
	}

	/**
	 * Une una lista de cadenas para formar una cadena separada por el delimitador con el que se llamó.
	 * entrada: "|".Concat("111", "222", "333", "abc")
	 * salida: "111|222|333|abc"
	 * @param words Una lista de cadenas separadas por comas
	 * @returns {String}
	 */
	static Concat(words*) {
		delim := this, s := ""
		for v in words
			s .= v . delim
		return SubStr(s, 1, -StrLen(this))
	}
}