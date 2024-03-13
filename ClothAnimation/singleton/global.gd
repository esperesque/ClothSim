extends Node

# Singleton for global simulation parameters

var GRID_X = 10
var GRID_Y = 10
var NODE_DISTANCE = 0.25 # Distance between points on the cloth
var K = 120 # Spring constant
var DAMPING = 40 # Damping amount
var MASS = 0.5 # Mass of all points on the cloth
var BEND_SPRINGS = true
var SHEAR_SPRINGS = true
var WIND_STRENGTH = 0.0
var WIND_DIR = Vector3(1, 0, 0)
var GRAVITY = 9.82
var SELECTED_SCENE = 0

enum{TOP_CORNERS, TOP_ROW, SINGLE_CORNER}
var FIXED_POINTS = TOP_ROW

enum{EULER, VERLET}
var INTEGRATION_METHOD = EULER

# Render settings
var SHOW_LINES = false
var SHOW_QUADS = true
var SHOW_POINTS = true
var SHOW_TEXTURE = false
