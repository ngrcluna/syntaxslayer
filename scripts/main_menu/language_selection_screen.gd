extends Control

var selected_language: String = ""
@onready var language_texture: TextureRect = $Compass
func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _on_python_button_pressed() -> void:
	selected_language = "Python"
	save_language_selection(selected_language)
	get_tree().change_scene_to_file("res://scenes/main/python_map/python_map.tscn")


func _on_cpp_button_pressed() -> void:
	selected_language = "CPP"
	language_texture.texture = preload("res://assets/ui/CPP_Compass.png")
	save_language_selection(selected_language)
	await get_tree().create_timer(0.05).timeout
#	get_tree().change_scene_to_file("res://scenes/main/python_map/_map")


func _on_c_button_pressed() -> void:
	selected_language = "C"
	language_texture.texture = preload("res://assets/ui/C_Compass.png")
	save_language_selection(selected_language)
	await get_tree().create_timer(0.05).timeout
#	get_tree().change_scene_to_file("res://scenes/main/python_map/c_map")


func _on_java_button_pressed() -> void:
	selected_language = "Java"
	language_texture.texture = preload("res://assets/ui/Java_Compass.png")
	save_language_selection(selected_language)
	await get_tree().create_timer(0.05).timeout
#	get_tree().change_scene_to_file("res://scenes/main/python_map/java_map")
	
# Database-ready function
func save_language_selection(language: String) -> void:
	print("Selected language: ", language)
