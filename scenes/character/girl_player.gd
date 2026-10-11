extends CharacterBody2D

@export var speed = 230
@onready var animated_sprite = $girl_player_animation
@export var animation_speed = 0.1

var can_move := true
var _default_mask: int

func _ready() -> void:
	_default_mask = collision_mask
	animated_sprite.animation_finished.connect(_on_eyes_animation_finished)
	call_deferred("set_spawn_position")


#KNOWLEDGE SCAN: GO INTO SCANNER + CLOSE EYES 

func enter_scanner(target_pos: Vector2) -> void:
	can_move = false
	velocity = Vector2.ZERO
	collision_mask = 0                     
	animated_sprite.play("girl_idle")
	var tween = create_tween()
	tween.tween_property(self, "global_position", target_pos, 0.4)
	await tween.finished
	animated_sprite.play("girl_closingeyes")


func _on_eyes_animation_finished() -> void:
	match animated_sprite.animation:
		"girl_closingeyes":
			FadeTransition.change_scene(
				"res://scenes/main/python_map/pre-assessment.tscn"
			)
		"girl_openingeyes":
			collision_mask = _default_mask
			can_move = true
			velocity = Vector2.ZERO
			animated_sprite.play("girl_idle")

# SPAWN POSITION
func set_spawn_position() -> void:
	var returning_from_scan: bool = SpawnManager.play_lying_up_on_spawn
	var target_name: String = SpawnManager.spawn_name
	if returning_from_scan:
		target_name = "ScannerSpawnPoint"
	if target_name != "":
		var spawn_point = get_tree().current_scene.find_child(target_name, true, false)
		if spawn_point:
			global_position = spawn_point.global_position
		else:
			push_warning("Spawn point not found: " + target_name)
		SpawnManager.spawn_name = ""
	# RETURNING FROM KNOWLEDGE SCAN
	if returning_from_scan:
		SpawnManager.play_lying_up_on_spawn = false
		_wake_up_from_scanner()
	else:
		can_move = true
		velocity = Vector2.ZERO
		animated_sprite.play("girl_idle")


func _wake_up_from_scanner() -> void:
	can_move = false
	velocity = Vector2.ZERO
	collision_mask = 0
	animated_sprite.animation = "girl_openingeyes"
	animated_sprite.frame = 0
	animated_sprite.pause()
	await get_tree().create_timer(0.1).timeout
	animated_sprite.play("girl_openingeyes")

# STOP / RESUME MOVEMENT
func stop_moving() -> void:
	can_move = false
	velocity = Vector2.ZERO
	animated_sprite.play("girl_idle")

func resume_moving() -> void:
	can_move = true
	velocity = Vector2.ZERO


# PLAYER MOVEMENT
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

	if input_direction.x != 0:
		animated_sprite.play("girl_walk")
		animated_sprite.flip_h = input_direction.x < 0
	elif input_direction.y < 0:
		animated_sprite.play("girl_upward")
	elif input_direction.y > 0:
		animated_sprite.play("girl_downward")
	else:
		animated_sprite.play("girl_idle")

	velocity = input_direction * speed

	move_and_slide()
