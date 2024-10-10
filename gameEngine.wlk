import wollok.game.*
// import colisiones.*
import vectores.*


package gameEngine {
	object window {
		var property width = 1200  // valores default de cantidad de casillas
		var property height = 900
		var property cellSize = 5
		var property titulo = "Wollok Game"

		method width() {
			return width
		}
		method width(_width) {
			if (game.running()) {
				console.println("No se puede cambiar el ancho de la ventana, el juego está corriendo.")
			}
			else {
				width = _width
			}
		}
		method height() {
			return height
		}
		method height(_height) {
			if (game.running()) {
				console.println("No se puede cambiar la altura de la ventana, el juego está corriendo.")
			}
			else {
				height = _height
			}
		}

		method width_in_cells() = width / cellSize
		method height_in_cells() = height / cellSize
		method center() = game.at(self.width_in_cells()/2, self.height_in_cells()/2)

		override method initialize() {
			super()
			game.width(self.width_in_cells()) // nro de celdas
			game.height(self.height_in_cells())
			game.cellSize(cellSize) // fijado a 1 píxel
			game.title(titulo)
			// game.ground("assets/background.png")
		}

		override method toString() = "window values: \n  .width: "+width.toString()+"\n  .height: "+height.toString()+"\n  .cellSize: "+cellSize.toString()+"\n  .titulo: "+titulo.toString()
	}

	object engine {
		method start() {
			game.start() // empezar el motor wollok game
		}

		method stop() {
			game.stop()
		}
	}

	object objects {

		const property objetosVisibles = new Set()
		const property objetos = new Set()

		method removeVisual(objeto) {
			const nombre = objeto.toString()+objeto.identity()
			console.println("SEARCHING: "+nombre)
			if (objetosVisibles.contains(objeto)) {
				game.removeVisual(objeto)
				objetosVisibles.remove(objeto)
				console.println("REMOVED: "+nombre)
			} 
			else {
				console.println("El visual \""+nombre+"\" no existe actualmente.")
			}
		}
		method addVisual(objeto) {
			game.addVisual(objeto)
			objetosVisibles.add(objeto)
		}
		method say(objeto, texto) {
			if (objetos.contains(objeto)) {
				game.say(objeto, texto)			
			} 
		}
	}

	// un actualizador global
	// se agregan objetos actualizables (osea que entienden el mensaje "update") 
	// y se actualizan en cada tick de programa 
	object updater {
		const update_list = new Set() // lista que almacena updatableObjects
		var prev_dt = null
		var property dt_global = null
		var enCamaraLenta = false
		
		// definimos como updatableObject a aquellos objetos que entienden el mensaje "update".
		method add(updatableObject) {
			update_list.add(updatableObject)
		}
		method remove(updatableObject) {
			update_list.remove(updatableObject)
		}
		
		method update(dt) {
			// envia el mensaje "update" a cada objeto guardado en la lista update_list
			update_list.forEach({updatableObject => updatableObject.update(dt)})
			// colisiones.checkearColisiones() 
		}
		
		// dt es el tiempo (en ms) que pasa por cada tick
		// framesPerTick son los numeros de frames por cada tick
		method start(dt) {
			game.onTick(dt, "updater", { self.update(dt) })	
			dt_global = dt	
		}
		
		method restart(dt) {
			self.stop()
			self.start(dt)
		}
		
		method stop() {
			game.removeTickEvent("updater")
		}
		
		method activarCamaraLenta() {
			if (not enCamaraLenta) {
				self.stop()
				prev_dt = dt_global // guardamos su estado actual
				dt_global *= 20	// cambiamos su valor
				game.onTick(dt_global, "updater", { self.update(prev_dt/3) })
				gameEngine.timeEvents.restartAllOnTickEvents()
				console.println("Camara lenta activada")
				
				sonidos.startSlowMotionIn_SFX()
				
			}
			enCamaraLenta = true
		}
		method desactivarCamaraLenta() {
			if (enCamaraLenta) {
				dt_global = prev_dt // restauramos el valor de dt_global
				self.restart(prev_dt) // volvemos a empezar el updater con los valores viejos
				gameEngine.timeEvents.restartAllOnTickEvents()
				console.println("Camara lenta desactivada")
				
				sonidos.startSlowMotionOut_SFX()
			}
			enCamaraLenta = false
		}
		method toggleCamaraLenta() {
			if (enCamaraLenta) {
				self.desactivarCamaraLenta()
			} else {
				self.activarCamaraLenta()
			}
			console.println("dt changed to:"+ dt_global)
		}
	}

	object timeEvents {  // kronos, dios del tiempo, controla los ticks del gameEngine
		const property allOnTicksEvents = new Set()
		
		method schedule(time, block) { // falta hacer que la camara lenta lo afecte
			game.schedule(time*updater.dt_global(), block)
		}
		method onTick(time, name, block) {
			allOnTicksEvents.add(new OnTickEvent(time=time, name=name, block=block)) // llevamos registro de estos eventos
			game.onTick(time*updater.dt_global(), name, block)
		}
		method restartAllOnTickEvents() {
			allOnTicksEvents.forEach { onTickEvent =>
				const time = onTickEvent.time()
				const name = onTickEvent.name()
				const block = onTickEvent.block()
				self.removeTickEvent(name)
				self.onTick(time, name, block) 
			}
		}
		method removeTickEvent(name) {
			console.println("BUSCANDO: "+name)
			try {
				const onTickEvent = allOnTicksEvents.find({ onTickEvent => onTickEvent.name() == name })
				game.removeTickEvent(name)
				allOnTicksEvents.remove(onTickEvent)
				console.println("ELIMINADO: "+name)
			} 
			catch e : ElementNotFoundException {
				console.println("El OnTickEvent \""+name+"\" no existe actualmente.")
			}
		}
		
	}

	object sonidos {
		const property musica = game.sound("assets/SONIDOS/musica.mp3")
		
		method playSound(path, volume) {
			const sonido = game.sound(path)
			sonido.volume(0.1)
			sonido.play()
		}
		
		method startMusic() {
			musica.shouldLoop(true)
			musica.volume(0.1)
			game.schedule(500, { musica.play()} )
		}
		
		method startSlowMotionIn_SFX() {
			const slowMotionIn = game.sound("assets/SONIDOS/cl-in.mp3")
			musica.volume(0.05)
			slowMotionIn.volume(0.5)
			game.schedule(1000, {musica.pause()})
	//		self.musica().pause()
			slowMotionIn.play()	
		}
		method startSlowMotionOut_SFX() {
			const slowMotionOut = game.sound("assets/SONIDOS/cl-out.mp3") 
			game.schedule(2500, {musica.resume()})
			slowMotionOut.play()
			musica.volume(0.1)
		}
	}




}

class OnTickEvent {
	const property time // esto es in-game time, la cámara lenta lo afectará
	const property name
	const property block
}

package primitives {

	class AbstractVisual {
		var property x = game.center().x()
		var property y = game.center().y()
		method position() = game.at(x,y) // es lo que wollok game lee para posicionarlo en la ventana
		
		override method initialize() {
			super()
			self.mostrar()
		}
		method mostrar() {
			gameEngine.objects.addVisual(self)
		}
		method ocultar() {
			gameEngine.objects.removeVisual(self)
		}
	}

	class Texto inherits AbstractVisual {
		var property text
		const property textColor
	}

	class Imagen inherits AbstractVisual {
		const height // en pixeles
		const width
		
		var property image
		
		override method position() {
			var current_x
			var current_y
			if (height!=null and width!=null) {
				current_x = x-(window.width_in_cells()/2)
				current_y = y-(window.height_in_cells()/2)
			} else {
				current_x = x
				current_y = y
			}
			return game.at(current_x, current_y)
		}
	}
}




