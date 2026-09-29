extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _process(_delta: float) -> void:
	pass


func _on_computer_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/map_reusables/video_screen.tscn")
