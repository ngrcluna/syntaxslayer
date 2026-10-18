extends Control
# start_screen.gd
func _ready() -> void:
	Gameprogress.hud_allowed = false
func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/character_setup/character_setup.tscn")


func _on_exit_button_pressed():
	get_tree().quit()


func _on_settings_button_pressed() -> void:
	pass # Replace with function body.
