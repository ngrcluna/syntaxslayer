extends Control

func _on_finish_button_pressed() -> void:

	# Mark the preassessment as completed
	Global.complete_preassessment(Global.current_language)

	SpawnManager.spawn_name = "ScannerSpawnPoint"
	SpawnManager.play_lying_up_on_spawn = true

	get_tree().change_scene_to_file("res://scenes/main/python_map/headquarters.tscn")
