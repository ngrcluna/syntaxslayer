
extends Node2D

var questions = [
	{
		"question": "1.\nname = \"Kleo\nprint(name)",
		"answer": "SyntaxError",
	},
	{
		"question": "2.\nage = \"21\"\nprint(age + 5)",
		"answer": "TypeError",
	},
	{
		"question": "3.\nprice = 99.50\nquantity = \"2\"\ntotal = price * quantity\nprint(total)",
		"answer": "TypeError",
	},
	{
		"question": "4.\nstudent_name = Kleo\nprint(student_name)",
		"answer": "NameError",
	},
	{
		"question": "5.\nscore = 95\nprint(\"Your score is \" + score)",
		"answer": "TypeError",
	}
]

var current_question
var lives = 3
var enemy_lives = 1
var is_processing_answer = false

@onready var question_label = $Control/QuestionPanel/Question
@onready var answer_input = $Control/AnswerPanel/Answer
@onready var submit_button = $Control/AnswerPanel/submit
@onready var rightorwrong = $Control/AnswerPanel/AnswerChecker

@onready var heart1: TextureRect = $Control/livescontainer/H1
@onready var heart2: TextureRect = $Control/livescontainer/H2
@onready var heart3: TextureRect = $Control/livescontainer/H3

@onready var enemy_heart: TextureRect = $Control/enemylife/heart

var HeartFull = preload("res://scenes/battle_system/battlesysMaterials/HeartRed.png")
var HeartNone = preload("res://scenes/battle_system/battlesysMaterials/HeartGray.png")

const SCHOOL_SCENE = "res://scenes/main/python_map/school.tscn"


func _ready() -> void:
	current_question = questions.pick_random()
	question_label.text = current_question["question"]

	update_lives()

	enemy_lives = 1
	enemy_heart.texture = HeartFull

	submit_button.pressed.connect(_on_submit_pressed)


func update_lives() -> void:
	heart1.texture = HeartFull if lives >= 1 else HeartNone
	heart2.texture = HeartFull if lives >= 2 else HeartNone
	heart3.texture = HeartFull if lives >= 3 else HeartNone


func animate_lost_heart(heart: TextureRect) -> void:
	if not is_inside_tree() or not is_instance_valid(heart):
		return

	for i in range(2):
		heart.texture = HeartNone
		await get_tree().create_timer(0.2).timeout

		if not is_inside_tree() or not is_instance_valid(heart):
			return

		heart.texture = HeartFull
		await get_tree().create_timer(0.2).timeout

		if not is_inside_tree() or not is_instance_valid(heart):
			return

	heart.texture = HeartNone


func animate_enemy_heart() -> void:
	if not is_inside_tree() or not is_instance_valid(enemy_heart):
		return

	for i in range(3):
		enemy_heart.texture = HeartNone
		await get_tree().create_timer(0.15).timeout

		if not is_inside_tree() or not is_instance_valid(enemy_heart):
			return

		enemy_heart.texture = HeartFull
		await get_tree().create_timer(0.15).timeout

		if not is_inside_tree() or not is_instance_valid(enemy_heart):
			return

	enemy_heart.texture = HeartNone


func _on_submit_pressed() -> void:
	if is_processing_answer or not is_inside_tree():
		return

	is_processing_answer = true
	submit_button.disabled = false

	var player_answer = answer_input.text.strip_edges().to_lower().replace(" ", "")
	var correct_answer = str(current_question["answer"]).strip_edges().to_lower().replace(" ", "")

	if player_answer == correct_answer:
		rightorwrong.text = "Right!"
		answer_input.editable = false
		enemy_lives = 0

		await animate_enemy_heart()

		if not is_inside_tree():
			return

		rightorwrong.text = "Enemy defeated!"
		get_tree().change_scene_to_file(SCHOOL_SCENE)
		return

	lives -= 1

	var lost_heart: TextureRect = null

	if lives == 2:
		lost_heart = heart3
	elif lives == 1:
		lost_heart = heart2
	elif lives == 0:
		lost_heart = heart1

	if is_instance_valid(lost_heart):
		await animate_lost_heart(lost_heart)

	if not is_inside_tree():
		return

	update_lives()

	if lives > 0:
		rightorwrong.text = "Wrong, Try again"
		answer_input.clear()
		submit_button.disabled = false
		is_processing_answer = false
	else:
		rightorwrong.text = "Game Over!"
		answer_input.editable = false

		await get_tree().create_timer(1.5).timeout

		if not is_inside_tree():
			return

		get_tree().change_scene_to_file(SCHOOL_SCENE)


func _on_cancel_pressed() -> void:
	if not is_inside_tree():
		return

	get_tree().change_scene_to_file(SCHOOL_SCENE)
