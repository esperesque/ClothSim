extends Panel

var pressed = false

func _ready():
	$WindLine.set_point_position(0, Vector2(140, 140))
	$WindLine.set_point_position(1, Vector2(140, 140))

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if event.position.x > global_position.x and event.position.x < global_position.x + 280:
				if event.position.y > global_position.y and event.position.y < global_position.y + 280:
					pressed = true
					$WindLine.set_point_position(1, event.position-global_position)
					update_wind()
		else:
			pressed = false
	if event is InputEventMouseMotion and pressed:
		if event.position.x > global_position.x and event.position.x < global_position.x + 280:
			if event.position.y > global_position.y and event.position.y < global_position.y + 280:
				$WindLine.set_point_position(1, event.position-global_position)
				update_wind()

func update_wind():
	Global.WIND_STRENGTH = (($WindLine.points[1] - $WindLine.points[0]).length()) * 0.3
	var wind_dir = $WindLine.points[1] - $WindLine.points[0]
	var wind3 = Vector3(wind_dir.y, 0, wind_dir.x)
	Global.WIND_DIR = wind3.normalized()
