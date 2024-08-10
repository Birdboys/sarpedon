extends Node2D

@onready var tileMap := $tileMap
@onready var startPoint := $startPoint
@onready var endPoint := $endPoint
@onready var navAgent := $startPoint/navAgent
@onready var tapestryImage := $tapestryLayer/tapestryImage
@onready var threadLine := $threadLine
@onready var cursor_pos : Vector2
@onready var prev_cursor_pos : Vector2
@onready var beginSpot : Vector2 
@onready var endSpot : Vector2
@onready var plus_tile_chance := 0.2
@onready var empty_tile_chance := 0.1
@onready var tile_size := 64
@onready var current_phase := "idle"
@export var x_dim := 6
@export var y_dim := 12
@export var num_blockers := 4
@export var gradient_interp := 0.0

signal weave_finished

func _ready():
	cursor_pos.x = x_dim/2 
	cursor_pos.y = y_dim/2
	prev_cursor_pos = cursor_pos
	setTapestryOffset(48)
	
func _process(_delta):
	match current_phase:
		"weaving":
			var input_dir = Vector2.ZERO
			if Input.is_action_just_pressed("forward"):
				input_dir += Vector2.UP
			if Input.is_action_just_pressed("left"):
				input_dir += Vector2.LEFT
			if Input.is_action_just_pressed("back"):
				input_dir += Vector2.DOWN
			if Input.is_action_just_pressed("right"):
				input_dir += Vector2.RIGHT
			if Input.is_action_just_pressed("interact"):
				AudioHandler.playSound("weave_tile")
				rotateTile(cursor_pos)
			if input_dir != Vector2.ZERO:
				AudioHandler.playSound("ui_click")
				moveCursor(input_dir)

func rotateTile(pos):
	var rot_tile = tileMap.get_cell_atlas_coords(0, pos).x
	var alt = tileMap.get_cell_alternative_tile(0, pos)
	match rot_tile:
		1:
			alt = wrap(alt+1, 0, 4)
		2:
			alt = wrap(alt+1, 0, 2)
		_:
			return
	tileMap.set_cell(0, pos, 0, Vector2(rot_tile, 0), alt)
	await NavigationServer2D.map_changed
	mapUpdated()
	
func mapUpdated():
	if navAgent.is_target_reachable():
		tileMap.clear_layer(1)
		current_phase = "finished"
		emit_signal("weave_finished")
	
func clearBoard():
	for x in range(x_dim):
		for y in range(y_dim):
			tileMap.set_cell(0, Vector2(x, y), 0, Vector2(0, 0))
	for x in [-1, x_dim]:
		for y in range(0, y_dim):
			tileMap.set_cell(0, Vector2(x, y))
	tileMap.clear_layer(1)
	threadLine.clear_points()
	cursor_pos.x = x_dim/2 
	cursor_pos.y = y_dim/2
	prev_cursor_pos = cursor_pos
			
func moveCursor(move_dir):
	cursor_pos += move_dir
	cursor_pos.x = clampi(cursor_pos.x, 0, x_dim-1)
	cursor_pos.y = clampi(cursor_pos.y, 0, y_dim-1)
	tileMap.set_cell(1, cursor_pos, 1, Vector2(0,0))
	if prev_cursor_pos != cursor_pos:
		tileMap.set_cell(1, prev_cursor_pos)
	prev_cursor_pos = cursor_pos

func setPath(path_points):
	for x in range(len(path_points)):
		var current_point = path_points[x]
		if x==0 or x==len(path_points)-1:
			tileMap.set_cell(0, current_point, 2, Vector2(0,0))
			continue
		var prev_point = path_points[x-1] if x>0 else Vector2i(current_point.x-1, current_point.y)
		var next_point = path_points[x+1] if x<len(path_points)-1 else Vector2i(current_point.x+1, current_point.y)
		var tile_info = getTileFromPath(current_point, prev_point, next_point)
		tileMap.set_cell(0, current_point, 0, Vector2(tile_info[0], 0), tile_info[1])

func newProblem():
	var path_points = getPathPoints()
	clearBoard()
	setPath(path_points)
	randomizeNonPathMap()
	cursor_pos.x = x_dim/2 
	cursor_pos.y = y_dim/2
	prev_cursor_pos = cursor_pos
	tileMap.set_cell(1, cursor_pos, 1, Vector2(0,0))
	current_phase = "weaving"

func continueProblem():
	var path_points = getPathPoints(beginSpot)
	clearBoard()
	setPath(path_points)
	randomizeNonPathMap()
	cursor_pos.x = x_dim/2 
	cursor_pos.y = y_dim/2
	prev_cursor_pos = cursor_pos
	tileMap.set_cell(1, cursor_pos, 1, Vector2(0,0))
	current_phase = "weaving"
	
func getTileFromPath(curr, prev, next):
	var next_dif = next - curr
	var prev_dif = curr - prev
	var difs = [prev_dif, next_dif]
	match [prev_dif, next_dif]:
		[Vector2i(1,0), Vector2i(1,0)], [Vector2i(-1,0), Vector2i(-1,0)]:
			return [2, 1] if randf() > plus_tile_chance else [3, 0]
		[Vector2i(0,1), Vector2i(0,1)], [Vector2i(0,-1), Vector2i(0,-1)]:
			return [2, 0] if randf() > plus_tile_chance else [3, 0]
		[Vector2i(0,1), Vector2i(1,0)]:
			return [1, 0]
		[Vector2i(0,-1), Vector2i(1,0)]:
			return [1, 1]
		[Vector2i(1,0), Vector2i(0,1)]:
			return [1, 2]
		[Vector2i(1,0), Vector2i(0,-1)]:
			return [1, 3]
		_:
			return [1,1]
			
func getPathPoints(beginning = null):
	var aGrid = AStarGrid2D.new()
	aGrid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	aGrid.region = Rect2(-1, 0, x_dim+2, y_dim)
	aGrid.update()
	
	beginSpot = beginning if beginning else Vector2(-1, randi_range(0, x_dim-1))
	endSpot = Vector2(x_dim, randi_range(0, y_dim-1))
	while endSpot.y == beginSpot.y:
		endSpot = Vector2(x_dim, randi_range(0, y_dim-1))

	for x in [-1, x_dim]:
		for y in range(0, y_dim):
			if Vector2(x, y) != beginSpot and Vector2(x, y) != endSpot:
				aGrid.set_point_solid(Vector2(x, y))

	var blockers = getBlockers(aGrid)
	while len(aGrid.get_id_path(beginSpot, endSpot)) == 0:
		blockers = getBlockers(aGrid, blockers)
	startPoint.position = tileMap.tile_set.tile_size.x * beginSpot + Vector2(tileMap.tile_set.tile_size)/2 
	endPoint.position = tileMap.tile_set.tile_size.x * endSpot + Vector2(tileMap.tile_set.tile_size)/2 
	navAgent.target_position = endPoint.position
	var path_points = aGrid.get_id_path(beginSpot, endSpot)
	return path_points

func randomizeNonPathMap():
	for x in range(x_dim):
		for y in range(y_dim):
			var current_cell_type = tileMap.get_cell_atlas_coords(0, Vector2(x, y)).x
			if current_cell_type == 0: #empty cell
				var rand = randf()
				if rand < 1.0 - empty_tile_chance:
					rand = randf()
					if rand < 0.33: 
						tileMap.set_cell(0, Vector2(x, y), 0, Vector2(2, 0), randi_range(0, 1))
					elif rand < 0.66:
						tileMap.set_cell(0, Vector2(x, y), 0, Vector2(3, 0))
					else: 
						tileMap.set_cell(0, Vector2(x, y), 0, Vector2(1, 0), randi_range(0, 3))
				else:
					tileMap.set_cell(0, Vector2(x, y), 0, Vector2(0,0))
			else:
				if current_cell_type == 1:
					tileMap.set_cell(0, Vector2(x, y), 0, Vector2(1, 0), randi_range(0, 3))
				if current_cell_type == 2:
					tileMap.set_cell(0, Vector2(x, y), 0, Vector2(2, 0), randi_range(0, 1))

func hideTapestry():
	AudioHandler.playSound("weave_tile")
	var tap_tween = get_tree().create_tween()
	tap_tween.tween_property(tileMap, "visible", true, 0.0)
	tap_tween.tween_property(tapestryImage, "material:shader_parameter/transparency", 0.0, 1.0)

func showTapestry():
	AudioHandler.playSound("weave_tile")
	var tap_tween = get_tree().create_tween()
	tap_tween.tween_property(tapestryImage, "material:shader_parameter/transparency", 1.0, 1.0)
	tap_tween.tween_property(tileMap, "visible", false, 0.0)
	
func revealThread(backward=false):
	current_phase = "threading"
	var nav_path = navAgent.get_current_navigation_path()
	var path_points = []
	for point in nav_path:
		var tile_cord = Vector2(int(point.x/tile_size), int(point.y/tile_size))
		if tile_cord not in path_points:
			path_points.append(tile_cord)
	await clearNonPath(path_points)
	await getLine(path_points) if not backward else await getLineBackwards(path_points)
	return
	

func clearNonPath(points):
	for x in range(x_dim-1, -1, -1):
		for y in range(0, y_dim):
			if Vector2(x, y) not in points:
				tileMap.set_cell(0, Vector2(x, y), 0, Vector2(0,0))
				
		await get_tree().create_timer(0.1).timeout

func getLine(points):
	#var line_tween = get_tree().create_tween()
	threadLine.clear_points()
	points.insert(0, points[0] + Vector2.LEFT)
	points.append(points[-1] + Vector2.RIGHT)
	AudioHandler.playSound("weave_tighten")
	for x in range(0, len(points)):
		var curr_point = points[x]
		var prev_point = points[x-1] if x != 0 else points[x] - Vector2(1, 0)
		var prev_dif = curr_point - prev_point
		var tile_center = points[x] * tile_size + Vector2.ONE * tile_size/2
		var prev_position = tile_center - prev_dif * tile_size/2
		if threadLine.get_point_count() > 0:
			threadLine.add_point(prev_position)
			threadLine.add_point(tile_center)
		else:
			threadLine.add_point(prev_position)
			threadLine.add_point(tile_center)
		await get_tree().create_timer(0.1).timeout
		

func getLineBackwards(points):
	var thread_tween = get_tree().create_tween()
	threadLine.clear_points()
	threadLine.modulate = Color.TRANSPARENT
	points.insert(0, points[0] + Vector2.LEFT)
	points.append(points[-1] + Vector2.RIGHT)
	threadLine.points = points.map(func(x): return x * tile_size + Vector2.ONE * tile_size/2)
	AudioHandler.playSound("weave_loosen")
	thread_tween.tween_property(threadLine, "modulate", Color.WHITE, 1.0)
	await thread_tween.finished
	for x in range(len(threadLine.points)-1, -1, -1):
		tileMap.set_cell(0, (threadLine.points[x]-Vector2.ONE * tile_size/2)/tile_size, 0, Vector2(0, 0))
		threadLine.remove_point(x)
		await get_tree().create_timer(0.1).timeout
	return

func getBlockers(aGrid, og_blockers=null):
	if og_blockers:
		for blocker in og_blockers:
			aGrid.set_point_solid(blocker, false)
			
	var blockers = []
	for x in range(num_blockers):
		var new_blocker = Vector2(randi_range(0,x_dim-1),randi_range(0,y_dim-1))
		while new_blocker in blockers:
			new_blocker = Vector2(randi_range(0,x_dim-1),randi_range(0,y_dim-1))
		blockers.append(new_blocker)
		aGrid.set_point_solid(new_blocker, true)
	return blockers

func setTapestryOffset(val, max_offset=0.1):
	tapestryImage.material.set_shader_parameter("num_sections", val)
	tapestryImage.material.set_shader_parameter("max_section_offset", max_offset)
