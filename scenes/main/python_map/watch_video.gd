extends Node2D
func _on_computer_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/map_reusables/video_screen.tscn")
