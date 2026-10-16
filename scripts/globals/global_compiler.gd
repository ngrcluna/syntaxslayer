extends CanvasLayer
@onready var toggle_button: Button = $CompilerToggleButton
@onready var compiler_bg: Control = $CompilerBG

func _ready() -> void:
	compiler_bg.hide()
	toggle_button.pressed.connect(_on_compiler_toggle_button_pressed)

func _on_compiler_toggle_button_pressed() -> void:
	compiler_bg.visible = not compiler_bg.visible
