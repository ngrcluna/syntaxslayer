extends Control

@onready var character_image = $Character

var characters = [
	{
		"id": "girl",
		"image": preload("res://assets/characters/girl_idle.png")
	},
	{
		"id": "boy",
		"image": preload("res://assets/characters/boy_idle.png")
	}
]

var current_character := 0
var selected_character := "girl"


func _ready() -> void:
	update_character()


func update_character() -> void:
	character_image.texture = characters[current_character]["image"]
	selected_character = characters[current_character]["id"]

func _process(_delta: float) -> void:
	pass

func _on_left_arrow_pressed() -> void:
	current_character -= 1
	if current_character < 0:
		current_character = characters.size() - 1
	update_character()

func _on_right_arrow_pressed() -> void:
	current_character += 1
	if current_character >= characters.size():
		current_character = 0
	update_character()

func _on_save_button_pressed() -> void:
	var start = Time.get_ticks_msec()
	get_tree().change_scene_to_file("res://scenes/language_selection/language_selection_screen.tscn")

func _on_clear_button_pressed() -> void:
	$"Name Edit/PlayerName".clear()


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/menu.tscn")
