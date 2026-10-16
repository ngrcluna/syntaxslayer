
extends Control

@onready var code_editor: TextEdit = $CodeEditor
@onready var input_box: TextEdit = $InputBox
@onready var run_button: Button = $RunButton
@onready var output_panel: RichTextLabel = $OutputPanel

func _ready() -> void:
	run_button.pressed.connect(_on_run_button_pressed)

func _on_run_button_pressed() -> void:
	output_panel.text = "Running Python..."

	var code_path := "user://student_code.py"
	var input_path := "user://student_input.txt"
	var runner_path := ProjectSettings.globalize_path(
        "res://python_runner.py"
	)

	var code_file := FileAccess.open(
		code_path, FileAccess.WRITE
	)
	if code_file == null:
		output_panel.text = "Could not save the code."
		return

	code_file.store_string(code_editor.text)
	code_file.close()

	var input_file := FileAccess.open(
		input_path, FileAccess.WRITE
	)
	if input_file == null:
		output_panel.text = "Could not save the input."
		return

	input_file.store_string(input_box.text)
	input_file.close()

	var code_absolute := ProjectSettings.globalize_path(
		code_path
	)
	var input_absolute := ProjectSettings.globalize_path(
		input_path
	)

	var result: Array = []
	var exit_code := OS.execute(
		"python",
		[runner_path, code_absolute, input_absolute],
		result,
		true
	)

	if exit_code == -1:
		output_panel.text = (
            "Could not start Python. Check your installation."
		)
	elif result.is_empty():
		output_panel.text = (
            "Program finished with no output. Exit code: "
			+ str(exit_code)
		)
	else:
		output_panel.text = str(result[0])
