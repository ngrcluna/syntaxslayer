extends Node

var current_language: String = "python"

var preassessment_completed: Dictionary = {}


func complete_preassessment(language: String) -> void:
	preassessment_completed[language] = true


func is_preassessment_completed(language: String) -> bool:
	return preassessment_completed.get(language, false)
