extends Node2D

var player_nearby: bool = false
@export var tap_prompt: Node2D
func _ready() -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not player_nearby:
		return
	if event is InputEventScreenTouch and event.pressed:
		if tap_prompt:
			tap_prompt.hide_prompt()
		_trigger_scan()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_trigger_scan()

func _trigger_scan() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("play_lay_down_animation"):
		player.play_lay_down_animation()
