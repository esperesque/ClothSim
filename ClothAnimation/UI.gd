extends CanvasLayer

var next_grid_x = Global.GRID_X
var next_grid_y = Global.GRID_Y

func _ready():
	%SizeXSpinBox.value = Global.GRID_X
	%SizeYSpinBox.value = Global.GRID_Y

func _on_restart_button_pressed():
	Global.GRID_X = next_grid_x
	Global.GRID_Y = next_grid_y
	Signals.restart_animation.emit()

func _on_size_x_spin_box_value_changed(value):
	next_grid_x = value

func _on_size_y_spin_box_value_changed(value):
	next_grid_y = value

func _on_k_spin_box_value_changed(value):
	Global.K = value

func _on_damping_spin_box_value_changed(value):
	Global.DAMPING = value

func _on_mass_spin_box_value_changed(value):
	Global.MASS = value

func _on_draw_lines_check_box_toggled(toggled_on):
	Global.SHOW_LINES = toggled_on
	#Signals.show_lines.emit(toggled_on)
	
func _on_euler_check_box_toggled(toggled_on):
	if toggled_on:
		Global.INTEGRATION_METHOD = 0
		print("using euler")

func _on_verlet_check_box_toggled(toggled_on):
	if toggled_on:
		Global.INTEGRATION_METHOD = 1
		print("using verlet")

func _on_top_corners_check_box_toggled(toggled_on):
	if toggled_on:
		Global.FIXED_POINTS = 0

func _on_top_row_check_box_toggled(toggled_on):
	if toggled_on:
		Global.FIXED_POINTS = 1

func _on_single_corner_check_box_toggled(toggled_on):
	if toggled_on:
		Global.FIXED_POINTS = 2

func _on_wind_spin_box_value_changed(value):
	Global.WIND_STRENGTH = value

func _on_shear_springs_check_box_toggled(toggled_on):
	Global.SHEAR_SPRINGS = toggled_on

func _on_bend_springs_check_box_toggled(toggled_on):
	Global.BEND_SPRINGS = toggled_on
