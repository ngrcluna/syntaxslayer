extends Control

@onready var progress_label = $QuizPanel/ProgressPanel/ProgressLabel
@onready var question_text = $QuizPanel/QuestionPanel/QuestionText
@onready var next_button = $NextButton
@onready var finish_button = $FinishButton
@onready var choice_buttons: Array = [
	$QuizPanel/A, $QuizPanel/B, $QuizPanel/C, $QuizPanel/D
]

var questions: Array = []
var current_index := 0
var selected_choice := ""
var score := 0
var answers: Array = []
var missed_topics := {}

func _ready() -> void:
	Gameprogress.hud_allowed = false
	finish_button.hide()
	_set_next_enabled(false)
	_style_choice_buttons()

	questions = Database.get_questions(
		Gameprogress.current_language.to_lower(), Gameprogress.current_stage)

	if questions.is_empty():
		question_text.text = "No questions available for this stage."
		for b in choice_buttons:
			b.hide()
		next_button.hide()
		finish_button.show()
		return

	questions.shuffle()

# One Button ONLY HEHEHEHE
	var group := ButtonGroup.new()
	for i in choice_buttons.size():
		choice_buttons[i].toggle_mode = true
		choice_buttons[i].button_group = group
		choice_buttons[i].pressed.connect(_on_choice_pressed.bind(i))

	next_button.pressed.connect(_on_next_pressed)

	await get_tree().process_frame
	_show_question()

# Adaptive Question Text Size. ADAPTIVE???!!!
const MAX_FONT := 50
const MIN_FONT := 16

func _fit_question_text() -> void:
	var font: Font = question_text.get_theme_font("font")
	var spacing: int = question_text.get_theme_constant("line_spacing")
	var box: Vector2 = question_text.size
	var txt: String = question_text.text.strip_edges()
	question_text.text = txt

	var chosen := MIN_FONT
	for s in range(MAX_FONT, MIN_FONT - 1, -2):
		var needed := font.get_multiline_string_size(
			txt, HORIZONTAL_ALIGNMENT_LEFT, box.x, s)
		var lines := int(round(needed.y / font.get_height(s)))
		var total_h: float = needed.y + spacing * maxi(lines - 1, 0)
		if total_h <= box.y - 8:   # 8px safety margin
			chosen = s
			break
	question_text.add_theme_font_size_override("font_size", chosen)
	
func _show_question() -> void:
	var q = questions[current_index]
	question_text.text = q.question
	_fit_question_text()
	selected_choice = ""
	_set_next_enabled(false)

	progress_label.text = "%s Stage %d - Q%d/%d" % [
		Gameprogress.current_language.capitalize(),
		Gameprogress.current_stage,
		current_index + 1,
		questions.size()
	]
	question_text.text = q.question

	var letters = ["A", "B", "C", "D"]
	for i in choice_buttons.size():
		var btn = choice_buttons[i]
		btn.set_pressed_no_signal(false)
		if i < q.choices.size():
			btn.text = "%s. %s" % [letters[i], q.choices[i].text]
			btn.show()
		else:
			btn.hide()


func _on_choice_pressed(index: int) -> void:
	selected_choice = questions[current_index].choices[index].id
	_set_next_enabled(true)

func _style_choice_buttons() -> void:
	var selected := StyleBoxFlat.new()
	selected.bg_color = Color(0.05, 0.28, 0.1)
	selected.border_color = Color(0.2, 1.0, 0.3)
	selected.set_border_width_all(3)
	selected.set_corner_radius_all(4)

	for btn in choice_buttons:
		btn.add_theme_stylebox_override("pressed", selected)
		btn.add_theme_stylebox_override("hover_pressed", selected)
		btn.add_theme_color_override("font_pressed_color", Color(0.6, 1.0, 0.65))
		btn.add_theme_color_override("font_hover_pressed_color", Color(0.6, 1.0, 0.65))
	for btn in choice_buttons:
		for state in ["normal", "hover", "pressed", "hover_pressed", "disabled", "focus"]:
			var sb = btn.get_theme_stylebox(state).duplicate()
			sb.content_margin_left = 20
			sb.content_margin_right = 20
			btn.add_theme_stylebox_override(state, sb)

func _on_next_pressed() -> void:
	if selected_choice == "":
		return

	var q = questions[current_index]
	var correct = Database.is_correct(q.id, selected_choice)
	answers.append({
		"question_id": q.id,
		"choice_id": selected_choice,
		"correct": correct
	})

	if correct:
		score += 1
	else:
		missed_topics[q.topic] = missed_topics.get(q.topic, 0) + 1

	current_index += 1
	if current_index >= questions.size():
		_show_results()
	else:
		_show_question()

func _show_results() -> void:
	for b in choice_buttons:
		b.hide()
	next_button.hide()
	finish_button.show()
	$QuizPanel/QuestionPanel.self_modulate.a = 0.0

	var total = questions.size()
	var percent = int(float(score) / total * 100.0)
	var text = "SCORE: %d/%d (%d%%)\n" % [score, total, percent]

	if missed_topics.is_empty():
		text += "Perfect! You're ready for this stage."
	else:
		text += "Work on:\n"
		for topic in missed_topics:
			text += "- %s\n" % Database.get_advice(topic)

	question_text.text = text
	await get_tree().process_frame
	_fit_question_text()

	Database.submit_attempt({
		"language": Gameprogress.current_language,
		"stage": Gameprogress.current_stage,
		"timestamp": Time.get_unix_time_from_system(),
		"answers": answers
	})


func _set_next_enabled(enabled: bool) -> void:
	next_button.disabled = not enabled
	next_button.modulate.a = 1.0 if enabled else 0.5   # dim when disabled


func _on_finish_button_pressed() -> void:
	var key = "%s_stage_%d" % [
		Gameprogress.current_language,
		Gameprogress.current_stage
	]
	Gameprogress.completed_knowledge_scans[key] = true

	SpawnManager.spawn_name = "ScannerSpawnPoint"
	SpawnManager.play_lying_up_on_spawn = true
	FadeTransition.change_scene("res://scenes/main/python_map/headquarters.tscn")
