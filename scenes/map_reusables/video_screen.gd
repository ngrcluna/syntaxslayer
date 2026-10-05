extends CanvasLayer

signal finished

@onready var video: VideoStreamPlayer = $VideoPlayer
@onready var play_button: Button = $PlayPauseButton
@onready var close_button: Button = $CloseButton

func _ready() -> void:
	load_current_video()


func load_current_video() -> void:

	var language = Gameprogress.current_language
	var stage = Gameprogress.current_stage

	var video_path = "res://assets/videos/%s/stage_%d.ogv" % [
		language.to_lower(),
		stage
	]

	var stream = load(video_path)

	if stream:
		video.stream = stream
		video.play()
		play_button.text = "Pause"
	else:
		print("Video not found: ", video_path)

func open(stream: VideoStream) -> void:
	video.stream = stream
	video.play()
	play_button.text = "Pause"

func _on_video_player_finished() -> void:

	var key = "%s_stage_%d" % [
		Gameprogress.current_language,
		Gameprogress.current_stage
	]

	Gameprogress.completed_videos[key] = true

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

	# TEMPORARY
	var key = "%s_stage_%d" % [
		Gameprogress.current_language,
		Gameprogress.current_stage
	]
	Gameprogress.completed_videos[key] = true

	SpawnManager.spawn_name = "girl"
	get_tree().change_scene_to_file("res://scenes/main/python_map/headquarters.tscn")
