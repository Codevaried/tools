/**
 * @file Timer.ahk
 * @version 0.2
 * @author Codevaried
 * @description
 * Esta clase proporciona la funcionalidad de un temporizador que permite iniciar, detener, reanudar, 
 * y resetear el tiempo transcurrido. También permite limpiar el tiempo transcurrido sin detener el temporizador.
 * 
 * Funciones incluidas:
 * - Start(): Inicia el temporizador desde el estado detenido o reseteado.
 * - Stop(): Detiene el temporizador y guarda el tiempo transcurrido.
 * - Resume(): Reanuda el temporizador desde donde fue detenido.
 * - Reset(): Resetea el temporizador a 0 y lo detiene.
 * - Clear(): Resetea el temporizador a 0 sin detenerlo.
 * 
 * Propiedades:
 * - ElapsedTime: Propiedad que devuelve el tiempo transcurrido en milisegundos.
 * - IsRunning: Propiedad que indica si el temporizador está en funcionamiento.
 * - StartTime: Propiedad que devuelve el tiempo de inicio del temporizador.
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
	 * Propiedad que devuelve el tiempo transcurrido en milisegundos.
	 * @returns {Integer} Tiempo transcurrido en milisegundos.
	 */
	ElapsedTime {
		get => this._isRunning ? this._elapsedTime + (A_TickCount - this._startTime) : this._elapsedTime
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