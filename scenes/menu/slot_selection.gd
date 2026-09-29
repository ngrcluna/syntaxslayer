extends Control
func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass


func _on_back_arrow_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/menu.tscn")


func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/character_setup/character_setup.tscn")
