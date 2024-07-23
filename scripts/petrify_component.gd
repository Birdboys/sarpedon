extends VisibleOnScreenNotifier3D

@onready var petrifyRay := $petrifyRay
@export var petrify_strength := 3.0
@export var petrify_length := 50.0
@export var enabled := false
@export var on_screen := false
@export var petrifying := false

var target_pos : Vector3

func _physics_process(delta):
	petrifying = false
	if not checkConditions(): return
	petrifyRay.target_position = to_local(target_pos).normalized() * petrify_length
	petrifyRay.force_raycast_update()
	var collider = petrifyRay.get_collider()
	if collider == null: 
		return
	if collider.has_method("petrify"):
		petrifying = true
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
func setRayPos(pos):
	petrifyRay.target_position = pos
