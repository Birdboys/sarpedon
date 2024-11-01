extends CSGCombiner3D

@export var brazier_noise : FastNoiseLite
@onready var light := $light

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	light.light_energy = 12 + 5 * brazier_noise.get_noise_1d(Time.get_ticks_msec()/1000)
