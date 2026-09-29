extends CharacterBody2D

@onready var animated_sprite = $npc_animation

func _ready() -> void:
	animated_sprite.play("npc_idle")


func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):

		animated_sprite.play("npc_active")

		var dialogue_manager = get_node("../Dialogue")

		# Check if this language's preassessment is completed
		if Global.is_preassessment_completed(Global.current_language):
			dialogue_manager.npc_state = "pre_assessment_complete"
		else:
			dialogue_manager.npc_state = "first_visit"

		# Start dialogue
		dialogue_manager.start_dialogue()


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		animated_sprite.play("npc_idle")
