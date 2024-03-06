extends MeshInstance3D

var neighbors = []
var neighbor_distance = []
var force:Vector3 = Vector3.ZERO
var velocity:Vector3 = Vector3.ZERO
var last_vel = Vector3.ZERO
var acceleration:Vector3 = Vector3.ZERO
var last_pos:Vector3 = Vector3.ZERO # used for verlet
var mass:float = 1.0

var fixed = false # If true, the position does not change

func apply_force(f:Vector3):
	force += f

func update_acceleration():
	if fixed:
		acceleration = Vector3.ZERO
	else:
		acceleration = force / mass

func update_position(delta):
	if fixed:
		return
	acceleration = force/mass

	velocity = Math.euler(velocity, acceleration, delta)
	last_pos = position # To allow switching between verlet and euler on the fly
	position = Math.euler(position, velocity, delta)
	
