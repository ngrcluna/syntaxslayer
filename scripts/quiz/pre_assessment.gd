extends Control

func _on_finish_button_pressed() -> void:

	var key = "%s_stage_%d" % [
		Gameprogress.current_language,
		Gameprogress.current_stage
	]

	Gameprogress.completed_knowledge_scans[key] = true

	print("Knowledge Scan completed: ", key)

	# Return to Headquarters
	SpawnManager.spawn_name = "ScannerSpawnPoint"
	SpawnManager.play_lying_up_on_spawn = true

	FadeTransition.change_scene("res://scenes/main/python_map/headquarters.tscn")
