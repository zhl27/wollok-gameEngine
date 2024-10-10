object trigonometria {
	method _seno_hasta90grados(x) {
		const pi = 3.1416
		const a = x * pi/180 // pasamos grados a radianes
		// Aproximacion del Seno con un polinomio de mclaurin de orden 9, es preciso entre -pi y pi.
		return a-((a**(3))/(6))+((a**(5))/(120))-((a**(7))/(5040)+((a**(9))/(362880)))
	}
	
  	method seno(x) { // es preciso entre -pi y pi
  		if (x < 0) { // para los negativos
  			return -self.seno(-x)
  		}
  		const a = x.abs()%360 // filtramos. Después de 360°, ya es todo lo mismo
  		if (a <= 90) {
  			return self._seno_hasta90grados(a)
  		} 
		if (a > 90 and a <= 180) {
  			return -self._seno_hasta90grados(a - 180)
  		}
  		// si es mayor a 180
  		return -self._seno_hasta90grados(a)
  	}
  	method coseno(x) { 
  		const a = 90 - x 
  		return self.seno(a)
  	}
}
