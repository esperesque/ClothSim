extends Node

# Singleton for mathematical utilities

func euler(y, dy, h):
	return y + (dy*h)

func verlet(y, y_prev, dt2, h):
	var arr = [] # Array for storing return values
	var y_last = y
	var y_next = 2*y - y_prev + pow(h, 2)*dt2
	var v_next = (1/(2*h)) * (y_next - y)
	return [y_last, y_next, v_next]
