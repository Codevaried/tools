/**
 * @file Highlight.ahk
 * @version 0.1
 * @author Codevaried
 * @description
 * Esta biblioteca proporciona funciones para resaltar áreas en la pantalla y seguir el cursor del mouse con resaltados coloridos.
 * 
 * Funciones incluidas:
 * - Highlight: Resalta un área con un borde colorido.
 * - MouseTip: Parpadea un resaltado colorido en un punto durante 2 segundos.
 * - FollowMouse: Resalta un área que sigue al puntero del mouse de manera fluida.
 * - GenerateHollowCircleRegion: Genera una cadena de región poligonal para un círculo hueco.
 * 
 * @credit Descolada, Coco
 * @note Esta es una versión modificada de la librería original <Misc.ahk Versión 0.3 (03.08.23)>. La versión original puede encontrarse en el repositorio oficial de Descolada.
 * Agradecimientos especiales a Descolada y Coco por la creación de esta magnífica librería y otras contribuciones.
 */


;;MARK:*
;^----------------GenerateHollowCircleRegion----------------^;

/**
 * Genera una cadena de región poligonal para un círculo hueco.
 * @param {Number} outerRadius - El radio del círculo exterior.
 * @param {Number} innerRadius - El radio del círculo interior.
 * @return {String} La cadena de región poligonal.
 */
GenerateHollowCircleRegion(outerRadius, innerRadius) {
	static Pi := 3.141592653589793
	points := ""
	steps := 360
	stepSize := 360 / steps
	;; Generar puntos para el borde exterior
	Loop steps {
		angle := A_Index * stepSize
		x := Round(outerRadius + outerRadius * Cos(angle * Pi / 180))
		y := Round(outerRadius + outerRadius * Sin(angle * Pi / 180))
		points .= x . "-" . y . " "
	}
	;; Generar puntos para el borde interior (en sentido contrario)
	Loop steps {
		angle := (steps - A_Index) * stepSize
		x := Round(outerRadius + innerRadius * Cos(angle * Pi / 180))
		y := Round(outerRadius + innerRadius * Sin(angle * Pi / 180))
		points .= x . "-" . y . " "
	}
	return points
}


;todo---MARK: GUI


;
;
;


;;MARK:*
;^----------------Highlight----------------^;

/**
 * Resalta un área con un borde colorido. Si se llama sin argumentos, se eliminan todos los resaltados.
 * Esta función también admite parámetros nombrados.
 * @param {Number} x - Coordenada X de la esquina superior izquierda del resaltado en la pantalla.
 * @param {Number} y - Coordenada Y de la esquina superior izquierda del resaltado en la pantalla.
 * @param {Number} w - Ancho del resaltado.
 * @param {Number} h - Alto del resaltado.
 * @param {Number|String} showTime - Puede ser uno de los siguientes:
 * * Sin establecer - si existe un resaltado, entonces se elimina; de lo contrario, resalta durante 2 segundos. Este es el valor predeterminado.
 * * 0 - Resaltado indefinido.
 * * Entero positivo (por ejemplo, 2000) - resaltará y pausará durante el tiempo especificado en ms.
 * * Entero negativo - resaltará durante el tiempo especificado en ms, pero la ejecución del script continuará.
 * * "clear" - elimina el resaltado incondicionalmente.
 * @param {String} color - El color del resaltado. Por defecto es rojo.
 * @param {Number} d - El grosor del borde del resaltado en píxeles. Por defecto es 2.
 * @param {Number} shape - La forma del resaltado (0 para rectángulo, 1 para círculo). Por defecto es 0.
 * @param {Boolean} model - Si es verdadero, solo crea la GUI y la devuelve.
 * @return {Object|Number} Devuelve el Objeto GUI si model es verdadero.
 */
Highlight(x?, y?, w?, h?, showTime?, color := "Red", d := 2, shape := 0, model := false) {
	static guis := Map(), timers := Map()

	CreateGui(x, y, w, h, color, d, shape) {
		GuiObj := Gui("+AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x08000000")
		GuiObj.BackColor := color

		if (shape = 1) {  ;; Círculo
			radius := w // 2
			regionStr := GenerateHollowCircleRegion(radius + d, radius)
			WinSetRegion(regionStr, GuiObj.Hwnd)
			GuiObj.Show("NA x" . (x - radius - d) . " y" . (y - radius - d) . " w" . (w + d * 2) . " h" . (h + d * 2))
		} else {  ;; Rectángulo
			iw := w + d, ih := h + d, w := w + d * 2, h := h + d * 2, x := x - d, y := y - d
			WinSetRegion("0-0 " w "-0 " w "-" h " 0-" h " 0-0 " d "-" d " " iw "-" d " " iw "-" ih " " d "-" ih " " d "-" d, GuiObj.Hwnd)
			GuiObj.Show("NA x" . x . " y" . y . " w" . w . " h" . h)
		}

		return GuiObj
	}

	if IsSet(x) { ;; si x está establecido, verificar si ya existe un resaltado en esas coordenadas
		if IsObject(x) {
			d := x.HasOwnProp("d") ? x.d : d, color := x.HasOwnProp("color") ? x.color : color, showTime := x.HasOwnProp("showTime") ? x.showTime : showTime
				, h := x.HasOwnProp("h") ? x.h : h, w := x.HasOwnProp("w") ? x.w : h, y := x.HasOwnProp("y") ? x.y : y, x := x.HasOwnProp("x") ? x.x : unset
		}
		if !(IsSet(x) && IsSet(y) && IsSet(w) && IsSet(h))
			throw ValueError("Los argumentos x, y, w y h deben proporcionarse todos para un resaltado", -1)
		for k, v in guis {
			if k.x = x && k.y = y && k.w = w && k.h = h { ;; el resaltado existe, por lo que eliminar o actualizar
				if !IsSet(showTime) || (IsSet(showTime) && showTime = "clear")
					TryRemoveTimer(k), TryDeleteGui(k)
				else if showTime = 0
					TryRemoveTimer(k)
				else if IsInteger(showTime) {
					if (showTime < 0) {
						if !timers.Has(k)
							timers[k] := Highlight.Bind(x, y, w, h)
						SetTimer(timers[k], showTime)
					} else {
						TryRemoveTimer(k)
						Sleep showTime
						TryDeleteGui(k)
					}
				} else
					throw ValueError('Valor de showTime inválido "' (!IsSet(showTime) ? "unset" : IsObject(showTime) ? "{Object}" : showTime) '"', -1)
				return
			}
		}
	} else { ;; si x no está establecido (por ejemplo, Highlight()), entonces eliminar todos los resaltados
		for k, v in timers
			SetTimer(v, 0)
		for k, v in guis
			v.Destroy()
		guis := Map(), timers := Map()
		return
	}

	if (showTime := showTime ?? 2000) = "clear"
		return
	else if !IsInteger(showTime)
		throw ValueError('Valor de showTime inválido "' (!IsSet(showTime) ? "unset" : IsObject(showTime) ? "{Object}" : showTime) '"', -1)

	;; De lo contrario, este es un nuevo resaltado
	loc := { x: x, y: y, w: w, h: h }

	GuiObj := CreateGui(x, y, w, h, color, d, shape)

	if model
		return GuiObj

	guis[loc] := GuiObj  ;; Guardar la GUI en el mapa para poder eliminarla más tarde

	if showTime > 0 {
		Sleep(showTime)
		TryDeleteGui(loc)
	} else if showTime < 0 {
		SetTimer(timers[loc] := Highlight.Bind(loc.x, loc.y, loc.w, loc.h), showTime)
	}

	TryRemoveTimer(key) {
		if timers.Has(key)
			SetTimer(timers[key], 0), timers.Delete(key)
	}
	TryDeleteGui(key) {
		if guis.Has(key)
			guis[key].Destroy(), guis.Delete(key)
	}
}


;todo---MARK: Mouse


;
;
;

;;MARK:*
;^----------------FollowMouse----------------^;

/**
 * Resalta un área que sigue al puntero del mouse de manera fluida.
 * @param {String} color - El color del borde del resaltado. Por defecto es rojo.
 * @param {Number} d - El grosor del borde del resaltado en píxeles. Por defecto es 2.
 * @param {Number} size - El tamaño del resaltado (diámetro del círculo). Por defecto es 30.
 * @param {Number} interval - El intervalo de actualización en ms. Por defecto es 50 ms.
 * @param {Number} shape - La forma del resaltado (0 para rectángulo, 1 para círculo). Por defecto es 1.
 */
FollowMouse(color := "Red", d := 3, size := 55, interval := 1, shape := 1) {

	/**
	 * Actualiza la posición del resaltado para seguir al puntero del mouse.
	 * @param {Object} GuiObj - La GUI del resaltado.
	 * @param {Number} size - El tamaño del resaltado (diámetro del círculo).
	 * @param {Number} d - El grosor del borde del resaltado en píxeles.
	 */
	UpdateMouseHighlight(GuiObj, size, d) {
		static lastX := -1, lastY := -1
		MouseGetPos(&x, &y)

		try {
			;; Obtener la posición de la ventana activa
			WinGetPos(&winX, &winY, , , "A")

			;; Ajustar la posición de la GUI relativa a la ventana activa
			if (x != lastX || y != lastY) {
				GuiObj.Move(x + winX - (size // 2) - d + 10, y + winY - (size // 2) - d + 10)
				lastX := x
				lastY := y
			}
		}
	}

	/**
	 * Mantiene la GUI en la parte superior.
	 * @param {Number} hwnd - El handle (HWND) de la GUI del resaltado.
	 */
	KeepGuiOnTop(hwnd) {
		if hwnd {
			WinSetAlwaysOnTop(1, "ahk_id " hwnd)
		}
	}

	/**
	 * Maneja el cierre de la GUI limpiando el temporizador.
	 * @param {Object} timer - El temporizador que necesita ser detenido.
	 * @param {Object} topTimer - El temporizador que mantiene la GUI en la parte superior.
	 */
	Gui_Close(timer, topTimer) {
		SetTimer(timer, 0)
		SetTimer(topTimer, 0)
	}

	static timer := 0, topTimer := 0, GuiObj

	;; Si el temporizador ya está en ejecución, detenerlo y limpiar el resaltado
	if (timer) {
		SetTimer(timer, 0)
		SetTimer(topTimer, 0)
		GuiObj.Destroy()
		timer := 0
		topTimer := 0
		return
	}

	;; Obtener la posición actual del mouse antes de crear la GUI
	MouseGetPos(&initialX, &initialY)
	WinGetPos(&winX, &winY, , , "A")

	;; Crear la GUI para el resaltado
	GuiObj := Highlight(0, 0, size, size, 0, color, d, shape, true) ;; Usamos modo modelo para crear la GUI

	;; Mover la GUI a la posición inicial del ratón
	GuiObj.Move(initialX + winX - (size // 2) - d + 10, initialY + winY - (size // 2) - d + 10)

	;; Establecer la posición inicial de la GUI correctamente
	static lastX := initialX, lastY := initialY

	;; Función para actualizar la posición del resaltado
	timerFunc := UpdateMouseHighlight.Bind(GuiObj, size, d)

	;; Iniciar el temporizador para actualizar la posición del resaltado
	SetTimer(timer := timerFunc, interval)

	;; Iniciar el temporizador para mantener la GUI en la parte superior
	SetTimer(topTimer := KeepGuiOnTop.Bind(GuiObj.Hwnd), 50)

	;; Manejar el cierre de la GUI para limpiar el temporizador
	GuiObj.OnEvent("Close", Gui_Close.Bind(timer, topTimer))
}


;;MARK:*
;^----------------MouseTip----------------^;

/**
 * Parpadea un resaltado colorido en un punto durante 2 segundos.
 * @param {Number} x - Coordenada X de la pantalla para el resaltado.
 *     Omite x o y para resaltar la posición actual del cursor.
 * @param {Number} y - Coordenada Y de la pantalla para el resaltado.
 * @param {String} color1 - Primer color para el resaltado. Por defecto es rojo.
 * @param {String} color2 - Segundo color para el resaltado. Por defecto es azul.
 * @param {Number} d - El grosor del borde del resaltado en píxeles. Por defecto es 2.
 * @param {Number} shape - La forma del resaltado (0 para rectángulo, 1 para círculo). Por defecto es 1.
 */
MouseTip(x?, y?, color1 := "red", color2 := "blue", d := 4, shape := 1) {
	if !(IsSet(x) && IsSet(y))
		MouseGetPos(&x, &y)

	varX := (shape = 1) ? 10 : 0  ;; Ajuste fino en X para círculos
	varY := (shape = 1) ? 10 : 0  ;; Ajuste fino en Y para círculos

	Loop 2 {
		Highlight(x - 10 + varX, y - 10 + varY, 20, 20, 500, color1, d, shape)
		Highlight(x - 10 + varX, y - 10 + varY, 20, 20, 500, color2, d, shape)
	}
	Highlight()
}