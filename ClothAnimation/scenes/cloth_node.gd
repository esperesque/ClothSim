extends MeshInstance3D

var neighbors = []
var neighbor_distance = []
var force:Vector3 = Vector3.ZERO
var velocity:Vector3 = Vector3.ZERO
var mass:float = 1.0

var fixed = false # If true, the position does not change

func apply_force(f:Vector3):
	force += f

func update_position(delta):
	if fixed:
		return
	var acc = force/mass

	velocity = Math.euler(velocity, acc, delta)
	position = Math.euler(position, velocity, delta)
