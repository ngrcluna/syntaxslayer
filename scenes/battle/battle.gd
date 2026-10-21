extends Control

const MAX_LIVES := 3
const heart_full: Texture2D = preload("res://assets/battle/full_heart.png")
const heart_loss: Texture2D = preload("res://assets/battle/lose_heart.png")

const QUESTION_PATH := "MarginContainer/HBoxContainer/QuestionContainer/Separator/"
const ANSWER_PATH := "MarginContainer/HBoxContainer/AnswerContainer/PanelContainer/MarginContainer/VBoxContainer/"

@onready var problem_number: Label = %ProblemNumber
@onready var question_label: Label = %Question
@onready var player_lives: HBoxContainer = %PlayerLives
@onready var enemy_life: HBoxContainer = %EnemyLife
@onready var player_sprite: CanvasItem = %Player
@onready var enemy_sprite: CanvasItem = %Enemy
@onready var code_edit: CodeEdit = %CodeEdit
@onready var cancel_button: BaseButton = %CancelButton
@onready var submit_button: BaseButton = %SubmitButton

var lives := MAX_LIVES
var question: Dictionary = {}
var locked := false


func _ready() -> void:
	Gameprogress.hud_allowed = false

	question = Gameprogress.current_question
	if question.is_empty():
		push_warning("No bug question loaded, leaving battle")
		Gameprogress.finish_bug_battle(false)
		return

	problem_number.text = "Problem No.1"
	question_label.text = question.get("question", "???")
	code_edit.placeholder_text = "Type your answer"

	submit_button.pressed.connect(_on_submit_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)
	
	(enemy_life.get_child(0) as TextureRect).texture = heart_full
	_update_hearts()
	code_edit.grab_focus()


func _exit_tree() -> void:
	Gameprogress.hud_allowed = true


# ANSWERING
func _on_submit_pressed() -> void:
	if locked:
		return
	var text := code_edit.text
	if text.strip_edges().is_empty():
		return

	if _is_correct(text):
		_win()
	else:
		_wrong()


func _is_correct(text: String) -> bool:
	var accepted = question.get("answers", [])
	if accepted is String:
		accepted = [accepted]
	var given := _normalize(text)
	for a in accepted:
		if given == _normalize(str(a)):
			return true
	return false


#
# "Type Error", "typeerror", "TYPE" and " type " all become "type"
func _normalize(s: String) -> String:
	var n := s.strip_edges().to_lower().replace(" ", "")
	if n.ends_with("error") and n.length() > 5:
		n = n.trim_suffix("error")
	return n


# OUTCOMES
func _wrong() -> void:
	lives -= 1
	_update_hearts()
	_shake(player_sprite)
	code_edit.text = ""
	if lives <= 0:
		_lose()


func _win() -> void:
	locked = true
	_shake(enemy_sprite)
	await _animate_enemy_heart()
	await get_tree().create_timer(0.5).timeout
	Gameprogress.finish_bug_battle(true)


func _lose() -> void:
	locked = true
	await get_tree().create_timer(0.8).timeout
	Gameprogress.finish_bug_battle(false)


func _on_cancel_pressed() -> void:
	if locked:
		return
	locked = true
	Gameprogress.finish_bug_battle(false)


# VISUALS
func _update_hearts() -> void:
	for i in player_lives.get_child_count():
		var heart := player_lives.get_child(i) as TextureRect
		heart.texture = heart_full if i < lives else heart_loss
		heart.modulate.a = 1.0


func _shake(node: CanvasItem) -> void:
	var start: Vector2 = node.position
	var t := create_tween()
	for i in 4:
		t.tween_property(node, "position:x", start.x + (6 if i % 2 == 0 else -6), 0.04)
	t.tween_property(node, "position", start, 0.04)


func _animate_enemy_heart() -> void:
	var heart := enemy_life.get_child(0) as TextureRect
	for i in 3:
		heart.texture = heart_loss
		await get_tree().create_timer(0.15).timeout
		heart.texture = heart_full
		await get_tree().create_timer(0.15).timeout
	heart.texture = heart_loss
