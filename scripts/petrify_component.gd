extends VisibleOnScreenNotifier3D

@onready var petrifyRay := $petrifyRay
@export var petrify_strength := 3.0
@export var petrify_length := 50.0
@export var enabled := false
@export var on_screen := false

var target_pos : Vector3

func _ready():
	petrifyRay.target_position = Vector3.FORWARD * petrify_length

func _physics_process(delta):
	if not checkConditions(): return
	petrifyRay.look_at(target_pos)
	petrifyRay.force_raycast_update()
	var collider = petrifyRay.get_collider()
	if collider == null: 
		return
	if collider.has_method("petrify"):
		collider.petrify(petrify_strength * delta)
		
func checkConditions():
	if not enabled: 
		return false
	if not is_on_screen():
		on_screen = false
		return false
	if target_pos == null: 
		return false
	if target_pos.distance_to(global_position) > petrify_length: 
		return false
	return true
	
func setTargetPos(pos):
	target_pos = pos
