extends StaticBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var shape: CollisionShape2D = $CollisionShape2D

var is_open := false

func _ready() -> void:
	anim.animation = "open"
	anim.frame = 0          # start closed
	anim.stop()

func open() -> void:
	if is_open:
		return
	is_open = true
	anim.play("opening")
	await anim.animation_finished
	shape.set_deferred("disabled", true)

func close() -> void:
	if not is_open:
		return
	is_open = false
	shape.set_deferred("disabled", false)
	anim.play_backwards("opening")
