extends Control

@onready var loadingbar = $ProgressBar
func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if loadingbar.value < 100:
		loadingbar.value += 50 * delta
	else:
		set_process(false)
		get_tree().change_scene_to_file("res://scenes/menu/menu.tscn")
