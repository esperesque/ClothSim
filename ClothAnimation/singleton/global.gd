extends Node

# Singleton for global simulation parameters

var GRID_X = 10
var GRID_Y = 10
var NODE_DISTANCE = 0.3 # Distance between points on the cloth
var K = 25 # Spring constant
var DAMPING = 8 # Damping amount
var MASS = 1.0 # Mass of all points on the cloth

enum{TOP_CORNERS, TOP_ROW, SINGLE_CORNER}
var FIXED_POINTS = TOP_ROW

enum{EULER, VERLET}
var INTEGRATION_METHOD = EULER

# Render settings
var SHOW_LINES = false
