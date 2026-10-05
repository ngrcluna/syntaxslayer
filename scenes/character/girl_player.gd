extends CharacterBody2D

@export var speed = 230
@onready var animated_sprite = $girl_player_animation
@export var animation_speed = 0.1

var can_move := true


func _ready() -> void:
	call_deferred("set_spawn_position")


# =========================================
# KNOWLEDGE SCAN: LIE DOWN
# =========================================

func play_lay_down_animation() -> void:
	can_move = false
	velocity = Vector2.ZERO

	animated_sprite.flip_h = true
	animated_sprite.play("lying_down")

	if not animated_sprite.animation_finished.is_connected(_on_lay_down_finished):
		animated_sprite.animation_finished.connect(_on_lay_down_finished)


func _on_lay_down_finished() -> void:
	if animated_sprite.animation == "lying_down":

		animated_sprite.animation_finished.disconnect(_on_lay_down_finished)

		get_tree().change_scene_to_file(
			"res://scenes/main/python_map/pre-assessment.tscn"
		)


# =========================================
# SPAWN POSITION
# =========================================

func set_spawn_position() -> void:

	# Set the player's spawn position
	if SpawnManager.spawn_name != "":
		
		var spawn_point = get_tree().current_scene.get_node_or_null(
			SpawnManager.spawn_name
		)

		if spawn_point:
			global_position = spawn_point.global_position

		SpawnManager.spawn_name = ""


	# =====================================
	# RETURNING FROM KNOWLEDGE SCAN
	# =====================================

	if SpawnManager.play_lying_up_on_spawn:

		SpawnManager.play_lying_up_on_spawn = false

		can_move = false
		velocity = Vector2.ZERO

		animated_sprite.play("lying_up")

		if not animated_sprite.animation_finished.is_connected(_on_lying_up_finished):
			animated_sprite.animation_finished.connect(_on_lying_up_finished)

	# =====================================
	# NORMAL ENTRANCE
	# =====================================

	else:

		can_move = true
		velocity = Vector2.ZERO

		animated_sprite.play("idle")


# =========================================
# FINISH LYING-UP ANIMATION
# =========================================

func _on_lying_up_finished() -> void:

	if animated_sprite.animation == "lying_up":

		animated_sprite.animation_finished.disconnect(
			_on_lying_up_finished
		)

		can_move = true
		velocity = Vector2.ZERO

		animated_sprite.play("idle")


# =========================================
# STOP / RESUME MOVEMENT
# =========================================

func stop_moving() -> void:
	can_move = false
	velocity = Vector2.ZERO
	animated_sprite.play("idle")


func resume_moving() -> void:
	can_move = true
	velocity = Vector2.ZERO


# =========================================
# PLAYER MOVEMENT
# =========================================

func _physics_process(_delta: float) -> void:

	if not can_move:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var input_direction = Input.get_vector(
		"left",
		"right",
		"up",
		"down"
	)

	# Horizontal movement
	if input_direction.x != 0:

		animated_sprite.play("walk")

		animated_sprite.flip_h = input_direction.x < 0

	# Moving upward
	elif input_direction.y < 0:

		animated_sprite.play("upward")

	# Moving downward
	elif input_direction.y > 0:

		animated_sprite.play("downward")

	# Not moving
	else:

		animated_sprite.play("idle")

	velocity = input_direction * speed

	move_and_slide()
