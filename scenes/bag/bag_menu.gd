extends CanvasLayer

@export var maps := {}   # { "Python": preload("res://maps/python_map.png") }

# Maps each language to its button on the compass image
const COMPASS_SPOTS := {
	"Python": "PythonButton",
	"C": "CButton",
	"C++": "CppButton",
	"Java": "JavaButton",
}

# Layout nodes (normal paths)
@onready var hub: PanelContainer = $Hub
@onready var screens: Control = $Screens

# Hub buttons (unique names)
@onready var profile_button: TextureButton = %ProfileButton
@onready var journal_button: TextureButton = %JournalButton
@onready var compiler_button: TextureButton = %CompilerButton
@onready var map_button: TextureButton = %MapButton
@onready var compass_button: TextureButton = %CompassButton
@onready var close_button: TextureButton = %CloseButton

# Screen contents (unique names)
@onready var profile_info: RichTextLabel = %ProfileInfo
@onready var entries: RichTextLabel = %Entries
@onready var picker: OptionButton = %LanguagePicker
@onready var code: CodeEdit = %Code
@onready var run_button: TextureButton = %RunButton
@onready var output: RichTextLabel = %Output
@onready var map_image: TextureRect = %MapImage
@onready var compass_image: TextureRect = %CompassImage



func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

	# Hub buttons
	profile_button.pressed.connect(_show_screen.bind("ProfileScreen"))
	journal_button.pressed.connect(_show_screen.bind("JournalScreen"))
	compiler_button.pressed.connect(_show_screen.bind("CompilerScreen"))
	map_button.pressed.connect(_show_screen.bind("MapScreen"))
	compass_button.pressed.connect(_show_screen.bind("CompassScreen"))
	close_button.pressed.connect(close)

	# Every screen's BackButton returns to the hub
	for screen in screens.get_children():
		screen.get_node("BackButton").pressed.connect(_show_hub)

	# Compiler
	for l in Gameprogress.LANGUAGES:
		picker.add_item(l)
	picker.item_selected.connect(_on_language_picked)
	run_button.pressed.connect(_on_run_pressed)

	# Compass spots
	#for lang in COMPASS_SPOTS:
	#	var spot: TextureButton = compass_image.get_node(COMPASS_SPOTS[lang])
	#	spot.pressed.connect(_travel.bind(lang))

# OPEN / CLOSE
signal opened
signal closed

func open() -> void:
	_refresh()
	_show_hub()
	visible = true
	get_tree().paused = true
	opened.emit()


func close() -> void:
	visible = false
	get_tree().paused = false
	closed.emit()


func _show_hub() -> void:
	hub.visible = true
	close_button.visible = true
	for s in screens.get_children():
		s.visible = false


func _show_screen(screen_name: String) -> void:
	hub.visible = false
	close_button.visible = false
	for s in screens.get_children():
		s.visible = (s.name == screen_name)


# REFRESH 
func _refresh() -> void:
	var lang := Gameprogress.current_language
	var kit := Gameprogress.has_kit(lang)

	
	journal_button.disabled = not kit
	map_button.disabled = not kit
	compiler_button.disabled = not Gameprogress.has_bag
	compass_button.disabled = not Gameprogress.has_bag

	map_image.texture = maps.get(lang)

	profile_info.text = "Language: %s\nStage: %d\nFirst stages cleared: %d / %d" % [
		lang,
		Gameprogress.current_stage,
		_count_first_stages_done(),
		Gameprogress.LANGUAGES.size(),
	]

	# Journal placeholder 
	entries.text = "%s journal" % lang

	# Compiler picker defaults to the current map's language
	picker.select(Gameprogress.LANGUAGES.find(lang))
	_on_language_picked(picker.selected)

	# Compass spots
	#for l in COMPASS_SPOTS:
	#	var spot: TextureButton = compass_image.get_node(COMPASS_SPOTS[l])
	#	spot.disabled = not _can_travel_to(l)


func _count_first_stages_done() -> int:
	var n := 0
	for l in Gameprogress.LANGUAGES:
		if Gameprogress.is_first_stage_done(l):
			n += 1
	return n


# COMPASS
func _can_travel_to(_language: String) -> bool:
	return true  


func _travel(language: String) -> void:
	Gameprogress.current_language = language
	Gameprogress.current_stage = 1
	close()
	# get_tree().change_scene_to_file("res://maps/%s_map.tscn" % language.to_lower())


# COMPILER 
func _on_language_picked(index: int) -> void:
	var lang: String = Gameprogress.LANGUAGES[index]
	var is_ready := Gameprogress.is_compiler_ready(lang)
	run_button.disabled = not is_ready
	output.text = "" if is_ready else "The %s compiler isn't set up yet." % lang


func _on_run_pressed() -> void:
	var lang: String = Gameprogress.LANGUAGES[picker.selected]
	match lang:
		"Python":
			_run_python(code.text)
		_:
			output.text = "The %s compiler isn't set up yet." % lang


func _run_python(source: String) -> void:
	if not OS.has_feature("android"):
		output.text = "Python execution requires Android."
		return

	if not Engine.has_singleton("GodotAndroidPluginTemplate"):
		output.text = "Python plugin not found!"
		return

	var python_plugin = Engine.get_singleton("GodotAndroidPluginTemplate")

	if python_plugin == null:
		output.text = "Plugin singleton is NULL."
		return

	output.text = "Running Python..."
	run_button.disabled = true

	var result = python_plugin.runPython(source)

	if result == null:
		output.text = "runPython returned NULL."
	else:
		output.text = str(result)

	run_button.disabled = false
