extends Node2D

@export var door_id := "scanner_room"

@onready var sprite: AnimatedSprite2D = $tap_with_arrow

func _ready() -> void:
	hide()
	Gameprogress.door_unlocked.connect(_on_door_unlocked)
	Gameprogress.door_locked.connect(_on_door_locked)

func _on_door_unlocked(id: String) -> void:
	if id == door_id:
		show_prompt()

func _on_door_locked(id: String) -> void:
	if id == door_id:
		hide_prompt()

func show_prompt() -> void:
	show()
	sprite.play("bouncing_tap")

func hide_prompt() -> void:
	hide()
	sprite.stop()
