extends Area2D

@export_file("*.tscn") var destination_scene: String
@export var destination_spawn: String
@export var interaction_text: String = ""
@export var requires_mission_start := true
@onready var interaction_label: Label = $Exit

var player_nearby: CharacterBody2D = null

func _ready() -> void:
	interaction_label.text = interaction_text
	interaction_label.visible = false
	Gameprogress.mission_started_changed.connect(_refresh_label)
	_refresh_label()

func _is_unlocked() -> bool:
	return not requires_mission_start or Gameprogress.mission_started

func _refresh_label() -> void:
	interaction_label.visible = player_nearby != null and _is_unlocked()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = body
		_refresh_label()

func _on_body_exited(body: Node2D) -> void:
	if body == player_nearby:
		player_nearby = null
		_refresh_label()

func _on_input_event(
	_viewport: Node,
	event: InputEvent,
	_shape_idx: int
) -> void:
	if player_nearby == null or not _is_unlocked():
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
	FadeTransition.change_scene(destination_scene)
