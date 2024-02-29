extends Node3D

var cloth_node = preload("res://scenes/cloth_node.tscn")
enum{EULER, VERLET}

# Dictionary containing all the cloth_node objects, with Vector2 objects as keys
var meshgrid = {}

var wind = 0.5
var wind_dir = Vector3(0.3, 0, 0.8).normalized()

# Called automatically when the main scene is ready
func _ready():
	setup_cloth()
	
	# Connect signals
	Signals.restart_animation.connect(setup_cloth)

# Called automatically every physics processing frame. delta is the time since the last frame
func _physics_process(delta):
	process_forces(delta)
		
	if Global.SHOW_LINES:
		draw_lines()

func process_forces(delta):
	for x in Global.GRID_X:
		for y in Global.GRID_Y:
			var n = meshgrid[Vector2(x,y)]
			n.force = Vector3.ZERO
			#if y < Global.GRID_Y-1:
				# Gravity
			if Global.WIND_STRENGTH > 0:
				n.apply_force(wind_dir*Global.WIND_STRENGTH)
			n.apply_force(Vector3(0, -1, 0)*n.mass)
			
			for n_index in n.neighbors.size():
				var n_coords = n.neighbors[n_index]
				var no = meshgrid[n_coords]
				var dvec = n.position - no.position
				var d = dvec.length()
				var norm = dvec.normalized()
				var ext = d - n.neighbor_distance[n_index] # Spring extension
				
				var vdif = no.velocity - n.velocity
				
				n.apply_force(-norm*ext*Global.K) # spring force
				n.apply_force(vdif*Global.DAMPING)

			if Global.INTEGRATION_METHOD == EULER:
				n.update_position(delta)
			elif Global.INTEGRATION_METHOD == VERLET:
				n.update_acceleration()
				var verlet_results = Math.verlet(n.position, n.last_pos, n.acceleration, delta)
				n.last_pos = verlet_results[0]
				n.position = verlet_results[1]
				n.velocity = verlet_results[2]

func setup_cloth():
	# Remove current cloth
	for c in $Cloth.get_children():
		c.queue_free()
	# Reset the meshgrid dictionary
	meshgrid = {}
	
	for x in Global.GRID_X:
		for y in Global.GRID_Y:
			var cn = cloth_node.instantiate()
			cn.position = Vector3(x*Global.NODE_DISTANCE, y*Global.NODE_DISTANCE, 0)
			cn.last_pos = cn.position
			cn.mass = Global.MASS
			match Global.FIXED_POINTS:
				0:
					if y == Global.GRID_Y - 1 and (x == 0 or x == Global.GRID_X - 1):
						cn.fixed = true
				1:
					if y == Global.GRID_Y - 1:
						cn.fixed = true
				2:
					if y == Global.GRID_Y - 1 and x == Global.GRID_X - 1:
						cn.fixed = true
	
			# Setup structural springs
			if x > 0:
				cn.neighbors.append(Vector2(x-1, y))
				cn.neighbor_distance.append(1.0*Global.NODE_DISTANCE)
			if y > 0:
				cn.neighbors.append(Vector2(x, y-1))
				cn.neighbor_distance.append(1.0*Global.NODE_DISTANCE)
			if x < Global.GRID_X-1:
				cn.neighbors.append(Vector2(x+1,y))
				cn.neighbor_distance.append(1.0*Global.NODE_DISTANCE)
			if y < Global.GRID_Y-1:
				cn.neighbors.append(Vector2(x,y+1))
				cn.neighbor_distance.append(1.0*Global.NODE_DISTANCE)
			
			# Setup shear springs
			
			if Global.SHEAR_SPRINGS:
				if x > 0:
					if y > 0:
						cn.neighbors.append(Vector2(x-1,y-1))
						cn.neighbor_distance.append(Vector2(1, 1).length()*Global.NODE_DISTANCE)
					if y < Global.GRID_Y-1:
						cn.neighbors.append(Vector2(x-1,y+1))
						cn.neighbor_distance.append(Vector2(1, 1).length()*Global.NODE_DISTANCE)
				if x < Global.GRID_X-1:
					if y > 0:
						cn.neighbors.append(Vector2(x+1,y-1))
						cn.neighbor_distance.append(Vector2(1, 1).length()*Global.NODE_DISTANCE)
					if y < Global.GRID_Y-1:
						cn.neighbors.append(Vector2(x+1,y+1))
						cn.neighbor_distance.append(Vector2(1, 1).length()*Global.NODE_DISTANCE)
			
			# Setup bend springs
			if Global.BEND_SPRINGS:
				if x > 1:
					cn.neighbors.append(Vector2(x-2, y))
					cn.neighbor_distance.append(2.0*Global.NODE_DISTANCE)
				if x < Global.GRID_X-2:
					cn.neighbors.append(Vector2(x+2, y))
					cn.neighbor_distance.append(2.0*Global.NODE_DISTANCE)
				if y > 1:
					cn.neighbors.append(Vector2(x, y-2))
					cn.neighbor_distance.append(2.0*Global.NODE_DISTANCE)
				if y < Global.GRID_Y-2:
					cn.neighbors.append(Vector2(x, y+2))
					cn.neighbor_distance.append(2.0*Global.NODE_DISTANCE)
				
			$Cloth.add_child(cn)
			meshgrid[Vector2(x,y)] = cn
	#$Cloth.position = Vector3(0, Global.NODE_DISTANCE*Global.GRID_Y, 0)
	$Cloth.position = Vector3(0, 2, 0)
	
func draw_lines():
	var cpos = $Cloth.position
	for x in Global.GRID_X:
		for y in Global.GRID_Y:
			if x < Global.GRID_X-1 and y < Global.GRID_Y-1:
				var n0 = meshgrid[Vector2(x,y)]
				var n1 = meshgrid[Vector2(x+1,y)]
				var n2 = meshgrid[Vector2(x, y+1)]
				Draw3D.line(n0.position+cpos, n1.position+cpos, Color.WHITE_SMOKE, 1)
				Draw3D.line(n0.position+cpos, n2.position+cpos, Color.WHITE_SMOKE, 1)
			elif x < Global.GRID_X-1:
				var n0 = meshgrid[Vector2(x,y)]
				var n1 = meshgrid[Vector2(x+1,y)]
				Draw3D.line(n0.position+cpos, n1.position+cpos, Color.WHITE_SMOKE, 1)
			elif y < Global.GRID_Y-1:
				var n0 = meshgrid[Vector2(x,y)]
				var n1 = meshgrid[Vector2(x,y+1)]
				Draw3D.line(n0.position+cpos, n1.position+cpos, Color.WHITE_SMOKE, 1)
