extends Node2D

@onready var tileMap := $tileMap
@onready var startPoint := $startPoint
@onready var endPoint := $endPoint
@onready var navAgent := $startPoint/navAgent
@onready var cursor_pos : Vector2
@onready var prev_cursor_pos : Vector2
@onready var beginSpot : Vector2 
@onready var endSpot : Vector2
@export var x_dim := 8
@export var y_dim := 8
@export var num_blockers := 12
func _ready():
	newProblem()
	cursor_pos.x = x_dim/2 
	cursor_pos.y = y_dim/2
	prev_cursor_pos = cursor_pos
	
func _process(delta):
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
		rotateTile(cursor_pos)
	#var input_dir = Input.get_vector("left", "right", "forward", "back")
	if input_dir != Vector2.ZERO:
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
		continueProblem()
	
func clearBoard():
	for x in range(x_dim):
		for y in range(y_dim):
			tileMap.set_cell(0, Vector2(x, y), 0, Vector2(0, 0))

func moveCursor(move_dir):
	cursor_pos += move_dir
	cursor_pos.x = clampi(cursor_pos.x, 0, x_dim-1)
	cursor_pos.y = clampi(cursor_pos.y, 0, y_dim-1)
	tileMap.set_cell(1, cursor_pos, 1, Vector2(0,0))
	tileMap.set_cell(1, prev_cursor_pos)
	prev_cursor_pos = cursor_pos

func setPath(path_points):
	for x in range(len(path_points)):
		var current_point = path_points[x]
		var prev_point = path_points[x-1] if x>0 else Vector2i(current_point.x-1, current_point.y)
		var next_point = path_points[x+1] if x<len(path_points)-1 else Vector2i(current_point.x+1, current_point.y)
		var tile_info = getTileFromPath(current_point, prev_point, next_point)
		tileMap.set_cell(0, current_point, 0, Vector2(tile_info[0], 0), tile_info[1])

func newProblem():
	var path_points = getPathPoints()
	clearBoard()
	setPath(path_points)
	randomizeNonPathMap()

func continueProblem():
	var path_points = getPathPoints(beginSpot)
	clearBoard()
	setPath(path_points)
	randomizeNonPathMap()
	
func getTileFromPath(curr, prev, next):
	var next_dif = next - curr
	var prev_dif = curr - prev
	#print(prev_dif, next_dif)
	var difs = [prev_dif, next_dif]
	match [prev_dif, next_dif]:
		[Vector2i(1,0), Vector2i(1,0)], [Vector2i(-1,0), Vector2i(-1,0)]:
			return [2, 1]
		[Vector2i(0,1), Vector2i(0,1)], [Vector2i(0,-1), Vector2i(0,-1)]:
			return [2, 0]
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
	aGrid.diagonal_mode =AStarGrid2D.DIAGONAL_MODE_NEVER
	aGrid.region = Rect2(0, 0, x_dim, y_dim)
	aGrid.update()
	
	beginSpot = beginning if beginning else Vector2(0, randi_range(0, x_dim-1))
	endSpot = Vector2(x_dim-1, randi_range(0, y_dim-1))
	var blockers = []
	for x in range(num_blockers):
		var new_blocker = Vector2(randi_range(0,x_dim-1),randi_range(0,y_dim-1))
		while new_blocker in blockers:
			new_blocker = Vector2(randi_range(0,x_dim-1),randi_range(0,y_dim-1))
			blockers.append(new_blocker)
			aGrid.set_point_solid(new_blocker)
	
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
				if rand < 0.1:
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
