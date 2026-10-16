extends CharacterBody2D

@export var speed = 230
@onready var animated_sprite = $boy_player_animation
@export var animation_speed = 0.1

var can_move := true

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed


func _physics_process(_delta):
	var input_direction = Input.get_vector("left", "right", "up", "down")

	if can_move:
		if input_direction.x != 0:
			animated_sprite.play("boy_walk")
			animated_sprite.flip_h = input_direction.x < 0
		elif input_direction.y < 0:
			animated_sprite.play("boy_upward")
		elif input_direction.y > 0:
			animated_sprite.play("boy_downward")
		else:
			animated_sprite.play("boy_idle")

		velocity = input_direction * speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		animated_sprite.play("idle")
