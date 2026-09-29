extends CanvasLayer

signal finished

@onready var video: VideoStreamPlayer = $VideoPlayer
@onready var play_button: Button = $PlayPauseButton
@onready var close_button: Button = $CloseButton

func _ready() -> void:
	pass

func open(stream: VideoStream) -> void:
	video.stream = stream
	video.play()
	play_button.text = "Pause"

func _on_video_player_finished() -> void:
	play_button.text = "Play again"
	finished.emit()

func _on_play_pause_button_pressed() -> void:
	if video.is_playing():
		video.paused = not video.paused
		play_button.text = "Play" if video.paused else "Pause"
	else:
		video.play()
		play_button.text = "Pause"

func _on_close_button_pressed() -> void:
	SpawnManager.spawn_name = "girl"
	get_tree().change_scene_to_file("res://scenes/main/python_map/headquarters.tscn")
