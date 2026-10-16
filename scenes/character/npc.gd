extends CharacterBody2D

@onready var animated_sprite = $npc_animation
@onready var dialogue = get_node_or_null("../Dialogue")
@onready var guide_arrow = $GuideArrow
@onready var guide_arrow_sprite = $GuideArrow/AnimatedSprite2D
@onready var dialogue_active := false


func _ready() -> void:
	animated_sprite.play("npc_idle")
	guide_arrow.hide()
	if dialogue == null:
		return

	dialogue.dialogue_started.connect(_on_dialogue_started)
	dialogue.dialogue_finished.connect(_on_dialogue_finished)

	dialogue.update_npc_state()
	if dialogue.npc_state == "first_visit" and not Gameprogress.met_npc_intro:
		show_guide_arrow()
	elif dialogue.npc_state in ["pre_assessment_complete", "journal_access"]:
		show_guide_arrow()

func _on_dialogue_started() -> void:
	dialogue_active = true
	animated_sprite.play("npc_active")
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("stop_moving"):
		player.stop_moving() 

func show_guide_arrow() -> void:
	guide_arrow.show()
	guide_arrow_sprite.play("arrow_bouncing") 

func hide_guide_arrow() -> void:
	guide_arrow_sprite.stop()
	guide_arrow.hide()



func _on_detection_area_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or dialogue_active:
		return
	if not body.has_method("stop_moving"):
		return
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
