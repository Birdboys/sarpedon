extends Camera3D
@onready var trauma := 0.0
@onready var trauma_reset_rate := 1.0
@onready var reset_rate := 1.0
@onready var camAnim := $camAnim
@onready var constant_trauma := false
@export var trauma_noise : FastNoiseLite

func _ready():
	pass # Replace with function body.

func _process(delta):
	if not constant_trauma:
		trauma = move_toward(trauma, 0.0, delta * trauma_reset_rate)
	if not camAnim.is_playing() and trauma == 0:
		v_offset = move_toward(v_offset, 0.0, delta * reset_rate)
		h_offset = move_toward(h_offset, 0.0, delta * reset_rate)

func addTrauma(val):
	trauma += val
	
func setTrauma(val, constant=false):
	trauma = val
	constant_trauma = constant
