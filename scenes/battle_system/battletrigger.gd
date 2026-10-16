
extends Area2D

var triggered := false
var DetectedError = preload("res://scenes/battle_system/battlesysMaterials/ErrorMessage.png")

func _on_body_entered(body: Node2D) -> void:
	if triggered:
		return

	if not body.is_in_group("player"):
		return

	triggered = true

	if "can_move" in body:
		body.can_move = false

	if body is CharacterBody2D:
		body.velocity = Vector2.ZERO

	if has_node("encounter"):
		$encounter.pitch_scale = 0.25
		$encounter.play()

	#TextureRect Node
	var message = body.get_node_or_null("Detected")

	if message != null:
		message.texture = DetectedError
		message.visible = true
	else:
		print("ERROR DETECTED")

	await get_tree().create_timer(0.5).timeout

	if not is_inside_tree():
		return

	get_tree().change_scene_to_file(
		"res://scenes/battle_system/Battle.tscn"
	)
