extends Node

signal lesson_finished(stream: VideoStream)

const SCREEN := preload("res://scenes/map_reusables/video_screen.tscn")

var _current: CanvasLayer
var _current_stream: VideoStream

func play(stream: VideoStream) -> void:
	if _current != null:
		return # already showing a video
	_current_stream = stream
	_current = SCREEN.instantiate()
	get_tree().current_scene.add_child(_current)
	_current.open(stream)
	_current.finished.connect(_on_screen_finished)
	_current.tree_exited.connect(_on_screen_closed)

func _on_screen_finished() -> void:
	lesson_finished.emit(_current_stream)

func _on_screen_closed() -> void:
	_current = null
	_current_stream = null
