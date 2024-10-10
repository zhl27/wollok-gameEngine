class Vector {
	var property x = 0
	var property y = 0
	
	override method toString() {
		return "Vector(" + x.toString() + ", " + y.toString() + ")"
	}
	
	method modulo() {
		return (x.square() + y.square()).squareRoot()
	}
	method magnitud() = self.modulo() // alias de modulo.
	
	method distanciaCon(otroVector) {
		return (otroVector - self).magnitud()
	}
	method versor() {
		return self/self.magnitud()
	}
	method vectorProyeccionSobre(otroVector) {
		/* El vector proyección de U sobre V es:
		 * el producto entre el versor de V 
		 * y el módulo de dicha proyección.
		 * Si el objetivo final es obtener el módulo del vector proyección, 
		 * usar directamente el método "escalarProyeccionSobre(otroVector)" 
		 * y NO: unVector.vectorProyeccionSobre(otroVector).modulo()
		 */
		return otroVector.versor() * self.escalarProyeccionSobre(otroVector)
	}
	method escalarProyeccionSobre(otroVector) {
		return (self % otroVector) / (otroVector.modulo())
	}
	
//	method apuntaHacia() {
//		if (x==0) {
//			if (y==0) {
//				return null // no apunta a nada
//			} 
//			if (y>0) {
//				return norte 
//			}
//			if (y<0) {
//				return sur
//			} 
//		}
//		if (x>0) {
//			if (x==y) {
//				return noreste
//			}
//			if (x==-y) {
//				return sureste
//			}
//			return este
//		}
//		else if (x<0) {
//			if (x==y) {
//				return suroeste
//			}
//			if (x==-y) {
//				return noroeste
//			}
//			return oeste
//		}
//		return null
//	}
	
	// como vector inmutable -> es horrible para la performance D:
	method +(otroVector) {
		return new Vector(x = x+otroVector.x(), y = y+otroVector.y())
	}
	method -(otroVector) {
		return new Vector(x = x-otroVector.x(), y = y-otroVector.y())
	}
	method *(escalar) {
		return new Vector(x = x*escalar, y = y*escalar)
	}
	method %(otroVector) { // usamos % para representar producto escalar entre dos vectores
		return x * otroVector.x() + y * otroVector.y()
	}
	method /(escalar) {
		return new Vector(x = x/escalar, y = y/escalar)
	}
	
	// como vector mutable -> impacta menos a la performance del juego, 
	// el juego va más fluido cuando trabajamos con variables x e y separadas.
	// asique utilizamos vectores solo para cambiar el property "position" de los objetos q es lo que le importa a wollok 
	method y(_y) {
		y = _y
	}
	method x(_x) {
		x = _x
	}
	method xy(_x, _y) {
		self.x(_x)
		self.y(_y)
	}
	method xy(_vector) {
		self.xy(_vector.x(), _vector.y())
	}
	method sumarle(otroVector) {
		x += otroVector.x()
		y += otroVector.y()
	}
	method sumarle(_x, _y) {
		x += _x
		y += _y
	}
	method restarle(otroVector) {
		x -= otroVector.x()
		y -= otroVector.y()
	}
	method restarle(_x, _y) {
		x -= _x
		y -= _y
	}
	method multiplicarle(escalar) {
		x *= escalar
		y *= escalar
	}
}

const versor_i = new Vector(x=1,y=0)
const versor_j = new Vector(x=0,y=1)


object vector {
	method at(_x, _y) {
		return new Vector(x=_x, y=_y)
	}
}


// cardinales 
object norte {
	method versor() {
		return new Vector(x=0,y=1)
	}
}
object sur {
	method versor() {
		return new Vector(x=0,y=-1)
	}
}
object este {
	method versor() {
		return new Vector(x=1,y=0)
	}
}
object oeste {
	method versor() {
		return new Vector(x=-1,y=0)
	}
}
object noreste {
	method versor() {
		return (new Vector(x=0.707,y=0.707)) // aproximadamente de magnitud 1, no necesitamos precision completa
	}
}
object noroeste {
	method versor() {
		return (new Vector(x=-0.707,y=0.707))
	}
}
object sureste {
	method versor() {
		return (new Vector(x=0.707,y=-0.707)) 
	}
}
object suroeste {
	method versor() {
		return (new Vector(x=-0.707,y=-0.707))
	}
}


