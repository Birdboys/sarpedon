extends RigidBody3D

@onready var state := "flying"
@onready var deleteTimer := $deleteTimer

signal landed

func thrown():
	await get_tree().create_timer(6).timeout
	if state == "flying":
		state = "landed"
		emit_signal("landed")
		deleteTimer.start(3)


func _on_body_entered(body):
	state = "landed"
	emit_signal("landed")
	deleteTimer.start(3)

func _on_delete_timer_timeout():
	queue_free()
