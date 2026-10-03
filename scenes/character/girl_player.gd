extends CharacterBody2D

@export var speed = 230
@onready var animated_sprite = $girl_player_animation
@export var animation_speed = 0.1
var can_move := true

func _ready() -> void:
	call_deferred("set_spawn_position")
	
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
		get_tree().change_scene_to_file("res://scenes/main/python_map/pre-assessment.tscn")

func set_spawn_position() -> void:
	if SpawnManager.spawn_name == "":
		animated_sprite.play("idle")
		return

	var spawn_point = get_tree().current_scene.get_node_or_null(SpawnManager.spawn_name)

	if spawn_point:
		global_position = spawn_point.global_position

	SpawnManager.spawn_name = ""

	if SpawnManager.play_lying_up_on_spawn:
		SpawnManager.play_lying_up_on_spawn = false
		can_move = false
		animated_sprite.play("lying_up")

		if not animated_sprite.animation_finished.is_connected(_on_lying_up_finished):
			animated_sprite.animation_finished.connect(_on_lying_up_finished)
	else:
		animated_sprite.play("idle")
		
func _on_lying_up_finished() -> void:
	if animated_sprite.animation == "lying_up":
		animated_sprite.animation_finished.disconnect(_on_lying_up_finished)
		can_move = true
		animated_sprite.play("idle")

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed

func _physics_process(_delta):
	if not can_move:
		velocity = Vector2.ZERO
		return  

	var input_direction = Input.get_vector("left", "right", "up", "down")

	if input_direction.x != 0:
		animated_sprite.play("walk")
		animated_sprite.flip_h = input_direction.x < 0
	elif input_direction.y < 0:
		animated_sprite.play("upward")
	elif input_direction.y > 0:
		animated_sprite.play("downward")
	else:
		animated_sprite.play("idle")

	velocity = input_direction * speed
	move_and_slide()
