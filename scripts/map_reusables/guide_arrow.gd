extends Node2D

@export var door_id := "video_room"

@onready var sprite: AnimatedSprite2D = $arrow_sprite

func _ready() -> void:
	hide()
	Gameprogress.door_unlocked.connect(_on_door_unlocked)
	Gameprogress.door_locked.connect(_on_door_locked)
	Gameprogress.video_completed.connect(hide_prompt)
	_refresh()

func _refresh() -> void:
	if Gameprogress.is_door_unlocked(door_id) and not Gameprogress.is_video_completed():
		show_prompt()
	else:
		hide_prompt()

func _on_door_unlocked(id: String) -> void:
	if id == door_id:
		_refresh()

func _on_door_locked(id: String) -> void:
	if id == door_id:
		hide_prompt()

func show_prompt() -> void:
	show()
	sprite.play("tap_bouncing")

func hide_prompt() -> void:
	sprite.stop()
	hide()
