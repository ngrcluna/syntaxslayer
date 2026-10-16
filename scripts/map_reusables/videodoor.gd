extends StaticBody2D

const ANIM := "vidroom_open"

@export var door_id := "video_room"

@onready var anim: AnimatedSprite2D = $VidDoor
@onready var shape: CollisionShape2D = $CollisionShape2D

var is_open := false

func _ready() -> void:
	anim.animation = ANIM
	anim.stop()
	Gameprogress.door_unlocked.connect(_on_door_unlocked)
	Gameprogress.door_locked.connect(_on_door_locked)
	if Gameprogress.is_door_unlocked(door_id):
		_set_open_instantly()
	else:
		anim.frame = 0

func _on_door_unlocked(id: String) -> void:
	if id == door_id:
		open()

func _on_door_locked(id: String) -> void:
	if id == door_id:
		close()

func open() -> void:
	if is_open:
		return
	is_open = true
	anim.play(ANIM)
	await anim.animation_finished
	if is_open:   # skip if it was closed again mid-animation
		shape.set_deferred("disabled", true)

func close() -> void:
	if not is_open:
		return
	is_open = false
	shape.set_deferred("disabled", false)   # block the player right away
	anim.play_backwards(ANIM)

func _set_open_instantly() -> void:
	is_open = true
	anim.frame = anim.sprite_frames.get_frame_count(ANIM) - 1
	shape.set_deferred("disabled", true)
