extends VisibleOnScreenNotifier3D

@onready var petrifyRay := $petrifyRay
@onready var can_see_player := false
@export var petrify_length := 50.0
@export var enabled := false
@export var can_petrify := false

var target_pos

func _ready():
	petrifyRay.target_position = Vector3.FORWARD * petrify_length
	
func _physics_process(_delta):
	can_see_player = false
	if not checkConditions(): return
	petrifyRay.look_at(target_pos)
	petrifyRay.force_raycast_update()
	if not petrifyRay.is_colliding(): 
		return
	var collider = petrifyRay.get_collider().get_parent()
	if collider.has_method("petrify"):
		if not collider.is_invis: 
			can_see_player = true
		if can_petrify and is_on_screen(): 
			collider.petrify()
	
func checkConditions():
	if not enabled: 
		return false
	if target_pos == null: 
		return false
	if global_position.distance_to(target_pos) > petrify_length: 
		return false
	return true
	
func setTargetPos(pos):
	target_pos = pos
