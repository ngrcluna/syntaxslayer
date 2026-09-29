extends Area2D

@export_file("*.tscn") var destination_scene: String
@export var destination_spawn: String
@export var interaction_text: String = "Tap to Enter"
@onready var interaction_label: Label = $Exit

var player_nearby: CharacterBody2D = null


func _ready() -> void:
	interaction_label.text = interaction_text
	interaction_label.visible = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = body
		interaction_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body == player_nearby:
		player_nearby = null
		interaction_label.visible = false


func _on_input_event(
	_viewport: Node,
	event: InputEvent,
	_shape_idx: int
) -> void:
	if player_nearby == null:
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			exit_door()
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			exit_door()

func exit_door() -> void:
	interaction_label.visible = false
	SpawnManager.spawn_name = destination_spawn
	get_tree().change_scene_to_file(destination_scene)
