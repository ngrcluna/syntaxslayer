extends CanvasLayer

@onready var container: HBoxContainer = $HBoxContainer
@onready var journal_button: TextureButton = $HBoxContainer/JournalButton
@onready var compiler_button: TextureButton = $HBoxContainer/CompilerButton


func _ready() -> void:
	container.grow_horizontal = Control.GROW_DIRECTION_BEGIN

	Gameprogress.tools_changed.connect(refresh)
	journal_button.pressed.connect(_on_journal_pressed)
	compiler_button.pressed.connect(_on_compiler_pressed)
	refresh()


func refresh() -> void:
	journal_button.visible = Gameprogress.has_journal
	compiler_button.visible = Gameprogress.has_compiler


func _on_journal_pressed() -> void:
	print("Open journal")


func _on_compiler_pressed() -> void:
	print("Open compiler")
