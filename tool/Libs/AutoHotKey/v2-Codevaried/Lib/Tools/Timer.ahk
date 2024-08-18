/**
 * @file Timer.ahk
 * @version 0.1
 * @author Codevaried
 * @description
 * Esta clase proporciona la funcionalidad de un temporizador que permite iniciar, detener, reanudar, 
 * y resetear el tiempo transcurrido. 
 * 
 * Funciones incluidas:
 * - Start(): Inicia el temporizador desde el estado detenido o reseteado.
 * - Stop(): Detiene el temporizador y guarda el tiempo transcurrido.
 * - Resume(): Reanuda el temporizador desde donde fue detenido.
 * - Reset(): Resetea el temporizador a 0.
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
	 * Resetea el temporizador a 0.
	 */
	Reset() {
		this._elapsedTime := 0
		this._isRunning := false
	}
}

;! Modo desarrollo: Hotkeys para recargar el script y salida rápida
#HotIf !A_IsCompiled and WinActive("ahk_exe Code.exe")
~^s:: Reload()   ;; Guarda y recarga el script
#HotIf

#HotIf !A_IsCompiled
^Esc:: ExitApp() ;; Salida de seguridad del script
#HotIf


;; Instanciando la clase Timer
t := Timer()


;; Test 0:
t.Start()
MsgBox(t.ElapsedTime . " ms")
MsgBox(t.ElapsedTime . " ms")
t.Reset()
MsgBox(t.ElapsedTime . " ms")
MsgBox(t.ElapsedTime . " ms")
t.Stop()


; ;; Test 1: Iniciar el temporizador
; t.Start()
; Sleep(1000)  ;; Esperar 1 segundo
; t.Stop()
; MsgBox("Test 1: ElapsedTime después de 1 segundo: " . t.ElapsedTime . " ms")  ;; Debería mostrar ~1000 ms

; ;; Test 2: Reanudar el temporizador
; t.Resume()
; Sleep(500)  ;; Esperar 0.5 segundos adicionales
; t.Stop()
; MsgBox("Test 2: ElapsedTime después de reanudar 0.5 segundos: " . t.ElapsedTime . " ms")  ;; Debería mostrar ~1500 ms

; ;; Test 3: Reiniciar el temporizador
; t.Reset()
; MsgBox("Test 3: ElapsedTime después de resetear: " . t.ElapsedTime . " ms")  ;; Debería mostrar 0 ms

; ;; Test 4: Verificar si el temporizador está corriendo
; t.Start()
; Sleep(300)
; MsgBox("Test 4: IsRunning (debería ser true): " . t.IsRunning)
; t.Stop()
; MsgBox("Test 4: IsRunning después de detener (debería ser false): " . t.IsRunning)

; ;; Test 5: Comenzar de nuevo y verificar el tiempo transcurrido
; t.Reset()
; t.Start()
; Sleep(700)  ;; Esperar 0.7 segundos
; t.Stop()
; MsgBox("Test 5: ElapsedTime después de 0.7 segundos: " . t.ElapsedTime . " ms")  ;; Debería mostrar ~700 ms
