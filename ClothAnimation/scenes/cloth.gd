extends Node3D

var cloth_node = preload("res://scenes/cloth_node.tscn")
var quad_mesh = preload("res://geometry/quad_mesh.tscn")
enum{EULER, VERLET}

@export var cloth_ver:int = 0

var meshgrid = {}
var quads = {}

# Called automatically every physics processing frame. delta is the time since the last frame
func _physics_process(delta):
	process_forces(delta)
	if Global.SHOW_TEXTURE:
		show_tex(true)
		update_quads()
	else:
		show_tex(false)
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
				n.apply_force(Global.WIND_DIR*Global.WIND_STRENGTH)
			n.apply_force(Vector3(0, -1*Global.GRAVITY, 0))
			
			# damping
			#var vdif = n.velocity - n.last_vel
			#vdif = n.velocity
			n.apply_force(-n.velocity*Global.DAMPING)
			
			for n_index in n.neighbors.size():
				var n_coords = n.neighbors[n_index]
				var no = meshgrid[n_coords]
				var dvec = n.position - no.position
				var d = dvec.length()
				var norm = dvec.normalized()
				var ext = d - n.neighbor_distance[n_index] # Spring extension
				
				n.apply_force(-norm*ext*Global.K) # spring force
				#n.apply_force(vdif*Global.DAMPING)
	for x in Global.GRID_X:
		for y in Global.GRID_Y:
			var n = meshgrid[Vector2(x,y)]
			if Global.INTEGRATION_METHOD == EULER:
				n.update_position(delta)
			elif Global.INTEGRATION_METHOD == VERLET:
				n.update_acceleration()
				var verlet_results = Math.verlet(n.position, n.last_pos, n.acceleration, delta)
				n.last_pos = verlet_results[0]
				if n.in_ball_scene:
					if (verlet_results[1]+position).distance_to(Vector3.ZERO) > 0.7:
						n.position = verlet_results[1]
					else:
						n.position = verlet_results[0]
				else:
					n.position = verlet_results[1]
				n.velocity = verlet_results[2]

func _ready():
	Signals.restart_animation.connect(setup_cloth)
	setup_cloth()

func setup_cloth():
	# Remove current cloth
	for c in get_children():
		if c.name != "texture":
			c.queue_free()
	for c in $texture.get_children():
		c.queue_free()
	# Reset the meshgrid dictionary
	meshgrid = {}
	
	for x in Global.GRID_X:
		for y in Global.GRID_Y:
			var cn = cloth_node.instantiate()
			if cloth_ver == 0:
				cn.position = Vector3(x*Global.NODE_DISTANCE, y*Global.NODE_DISTANCE, 0)
			elif cloth_ver == 1:
				cn.position = Vector3(x*Global.NODE_DISTANCE, 0, -y*Global.NODE_DISTANCE)
				cn.in_ball_scene = true
			cn.last_pos = cn.position
			cn.mass = Global.MASS
			if cloth_ver == 0:
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
						if y > 1:
							cn.neighbors.append(Vector2(x-2,y-2))
							cn.neighbor_distance.append(sqrt(8)*Global.NODE_DISTANCE)
						if y < Global.GRID_Y-2:
							cn.neighbors.append(Vector2(x-2,y+2))
							cn.neighbor_distance.append(sqrt(8)*Global.NODE_DISTANCE)
					if y > 1:
						cn.neighbors.append(Vector2(x, y-2))
						cn.neighbor_distance.append(2.0*Global.NODE_DISTANCE)
					if x < Global.GRID_X-2:
						cn.neighbors.append(Vector2(x+2,y))
						cn.neighbor_distance.append(2.0*Global.NODE_DISTANCE)
						if y > 1:
							cn.neighbors.append(Vector2(x+2,y-2))
							cn.neighbor_distance.append(sqrt(8)*Global.NODE_DISTANCE)
						if y < Global.GRID_Y-2:
							cn.neighbors.append(Vector2(x+2,y+2))
							cn.neighbor_distance.append(sqrt(8)*Global.NODE_DISTANCE)
					if y < Global.GRID_Y-2:
						cn.neighbors.append(Vector2(x,y+2))
						cn.neighbor_distance.append(2.0*Global.NODE_DISTANCE)
				
			add_child(cn)
			meshgrid[Vector2(x,y)] = cn
	#$Cloth.position = Vector3(0, Global.NODE_DISTANCE*Global.GRID_Y, 0)
	position = Vector3(-1.5, 2, 1.5)
	
	#if Global.SHOW_QUADS:
	quads = {}
	for x in Global.GRID_X-1:
		for y in Global.GRID_Y-1:
			var qm = quad_mesh.instantiate()
			qm.v0 = meshgrid[Vector2(x,y)].position
			qm.v1 = meshgrid[Vector2(x,y+1)].position
			qm.v2 = meshgrid[Vector2(x+1,y+1)].position
			qm.v3 = meshgrid[Vector2(x+1,y)].position
			
			var w = 1.0 / float(Global.GRID_X)
			var h = 1.0 / float(Global.GRID_Y)
			
			qm.uv_bl = Vector2(x*w, y*h) #0, 0
			qm.uv_br = Vector2((x+1)*w, y*h) #1, 0
			qm.uv_tr = Vector2((x+1)*w, (y+1)*h) #1, 1
			qm.uv_tl = Vector2(x*w, (y+1)*h) #0, 1
			$texture.add_child(qm)
			quads[Vector2(x,y)] = qm

func update_quads():
	for x in Global.GRID_X-1:
		for y in Global.GRID_Y-1:
			var qm = quads[Vector2(x,y)]
			qm.v0 = meshgrid[Vector2(x,y)].position
			qm.v1 = meshgrid[Vector2(x,y+1)].position
			qm.v2 = meshgrid[Vector2(x+1,y+1)].position
			qm.v3 = meshgrid[Vector2(x+1,y)].position
			qm.update()

func show_tex(b):
	$texture.visible = b
	
func draw_lines():
	var cpos = position
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
