extends CharacterBody2D

@onready var animated_sprite = $npc_animation
@onready var dialogue = get_node("../Dialogue")

var dialogue_active := false


func _ready() -> void:
	animated_sprite.play("npc_idle")
	dialogue.dialogue_finished.connect(_on_dialogue_finished)


func _on_detection_area_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or dialogue_active:
		return
	if not body.has_method("stop_moving"):
		return

	dialogue_active = true
	body.stop_moving()
	animated_sprite.play("npc_active")
	dialogue.start_dialogue()


func _on_dialogue_finished() -> void:
	dialogue_active = false
	animated_sprite.play("npc_idle")
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.resume_moving()


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") and not dialogue_active:
		animated_sprite.play("npc_idle")
