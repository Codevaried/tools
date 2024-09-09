/**
 * @file Timer.ahk
 * @version 0.3
 * @author Codevaried
 * @description
 * Esta clase proporciona la funcionalidad de un temporizador que permite iniciar, detener, reanudar, 
 * y resetear el tiempo transcurrido. También permite limpiar el tiempo transcurrido sin detener el temporizador.
 * Además, proporciona la capacidad de obtener el tiempo transcurrido en un formato personalizado.
 * 
 * Funciones incluidas:
 * - Start(): Inicia el temporizador desde el estado detenido o reseteado.
 * - Stop(): Detiene el temporizador y guarda el tiempo transcurrido.
 * - Resume(): Reanuda el temporizador desde donde fue detenido.
 * - Reset(): Resetea el temporizador a 0 y lo detiene.
 * - Clear(): Resetea el temporizador a 0 sin detenerlo.
 * - GetElapsedTime(): Devuelve el tiempo transcurrido en un formato personalizado.
 * 
 * Propiedades:
 * - ElapsedTime[unit := "ms"]: Propiedad que devuelve el tiempo transcurrido en la unidad especificada.
 * - IsRunning: Propiedad que indica si el temporizador está en funcionamiento.
 * - StartTime: Propiedad que devuelve el tiempo de inicio del temporizador.
 * 
 * Ejemplo de uso:
 *   myTimer := Timer()
 *   myTimer.Start()
 *   Sleep(3500)
 *   elapsedFormatted := myTimer.GetElapsedTime("<m> minutos, <s> segundos, <ms> milisegundos")
 *   MsgBox(elapsedFormatted)  ;; Muestra: "0 minutos, 3 segundos, 500 milisegundos"
 */

class Timer {
	;; Variables de instancia (privadas)
	_elapsedTime := 0   ;; Tiempo transcurrido en milisegundos
	_isRunning := false ;; Estado del temporizador
	_startTime := 0     ;; Tiempo en que se inició el temporizador

	;; Constructor
	__New() {
		this.Reset()
	}

	;;MARK:*
	;^----------------Propiedades (Getters)----------------^;

	/**
	 * Propiedad que devuelve el tiempo transcurrido en la unidad especificada.
	 * @param unit {String} Unidad de tiempo. Puede ser "ms" (milisegundos), "s" (segundos), "m" (minutos), o "h" (horas).
	 * @returns {Float|Integer} Tiempo transcurrido en la unidad especificada.
	 */
	ElapsedTime[unit := "ms"] {
		get {
			elapsed := this._isRunning ? this._elapsedTime + (A_TickCount - this._startTime) : this._elapsedTime
			switch unit {
				case "s":
					return elapsed / 1000
				case "m":
					return elapsed / 60000
				case "h":
					return elapsed / 3600000
				default:
					return elapsed ;; Devuelve en milisegundos por defecto
			}
		}
	}

	/**
	 * Propiedad que indica si el temporizador está en funcionamiento.
	 * @returns {Boolean} true si el temporizador está corriendo, false en caso contrario.
	 */
	IsRunning {
		get => this._isRunning
	}

	/**
	 * Propiedad que devuelve el tiempo de inicio del temporizador.
	 * @returns {Integer} Tiempo de inicio del temporizador en milisegundos.
	 */
	StartTime {
		get => this._startTime
	}

	;;MARK:*
	;^----------------Funciones----------------^;

	/**
	 * Devuelve el tiempo transcurrido en un formato personalizado.
	 * @param {string} format - Cadena de formato personalizada. Los marcadores válidos son:
	 *                          <h> para horas, <m> para minutos, <s> para segundos, <ms> para milisegundos.
	 *                          Si no se especifica, devuelve el tiempo en el formato estándar <h>:<m>:<s>.<ms>.
	 * @returns {string} - Tiempo transcurrido en el formato especificado.
	 *                     Ejemplo de formato personalizado: "<m> minutos, <h> horas".
	 */
	GetElapsedTime(format?) {
		elapsed := this.ElapsedTime["ms"]

		;; Convertir el tiempo transcurrido a horas, minutos, segundos y milisegundos
		hours := Floor(elapsed / 3600000)
		minutes := Floor((elapsed - (hours * 3600000)) / 60000)
		seconds := Floor((elapsed - (hours * 3600000) - (minutes * 60000)) / 1000)
		milliseconds := elapsed - (hours * 3600000) - (minutes * 60000) - (seconds * 1000)

		;; Si el formato está vacío, devolver en formato por defecto <h>:<m>:<s>.<ms>
		if !IsSet(format)
			return hours ":" minutes ":" seconds "." milliseconds

		;; Reemplazar los marcadores en la cadena de formato
		format := StrReplace(format, "<h>", hours)
		format := StrReplace(format, "<m>", minutes)
		format := StrReplace(format, "<s>", seconds)
		format := StrReplace(format, "<ms>", milliseconds)

		return format
	}

	/**
	 * Inicia el temporizador desde el estado detenido o reseteado.
	 */
	Start() {
		if !this._isRunning {
			this._startTime := A_TickCount
			this._isRunning := true
		}
	}

	/**
	 * Detiene el temporizador y guarda el tiempo transcurrido.
	 */
	Stop() {
		if this._isRunning {
			this._elapsedTime += A_TickCount - this._startTime
			this._isRunning := false
		}
	}

	/**
	 * Reanuda el temporizador desde donde fue detenido.
	 */
	Resume() {
		if !this._isRunning {
			this._startTime := A_TickCount
			this._isRunning := true
		}
	}

	/**
	 * Resetea el temporizador a 0 y lo detiene.
	 */
	Reset() {
		this._elapsedTime := 0
		this._isRunning := false
	}

	/**
	 * Resetea el temporizador a 0 sin detenerlo.
	 */
	Clear() {
		this._elapsedTime := 0
		; Mantiene el temporizador corriendo
		if this._isRunning {
			this._startTime := A_TickCount ; Reinicia el tiempo de inicio para que ElapsedTime sea correcto
		}
	}
}