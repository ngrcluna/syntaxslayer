extends Area2D

@export var question_pool: String = ""
@export var popup_duration: float = 1.5
@export_file("*.tscn") var battle_scene: String = "res://scenes/battle/battle.tscn"
@onready var error_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var error_popup: Control = $CanvasLayer/ErrorPopup

var triggered := false


func _ready() -> void:
	add_to_group("bug_zones")
	error_popup.hide()
	if Gameprogress.is_bug_zone_cleared(name):
		queue_free()
		return


func _on_body_entered(body: Node2D) -> void:
	if triggered or not body.is_in_group("player"):
		return
	triggered = true
	body.stop_moving()

	var stage := get_tree().current_scene
	Gameprogress.start_bug_battle(stage.scene_file_path, body.global_position, name, question_pool)

	error_popup.show()
	error_sound.play()

	var tween := create_tween().set_loops(6)
	tween.tween_property(error_popup, "modulate:a", 0.3, 0.05)
	tween.tween_property(error_popup, "modulate:a", 1.0, 0.05)

	await get_tree().create_timer(popup_duration).timeout
	FadeTransition.change_scene(battle_scene)
