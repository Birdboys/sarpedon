extends Node

signal load_finished

func startLoad():
	ResourceLoader.load_threaded_request("res://assets/temp/test_island.tscn")
	checkLoad()
	
func checkLoad():
	var res = ResourceLoader.load_threaded_get_status("res://assets/temp/test_island.tscn")
	if res == ResourceLoader.THREAD_LOAD_LOADED:
		emit_signal("load_finished")
	else:
		var loadTimer = get_tree().create_timer(0.1)
		loadTimer.timeout.connect(checkLoad)

func retrieveLoad():
	var result = ResourceLoader.load_threaded_get("res://assets/temp/test_island.tscn")
	return result
