extends Node2D

@onready var girl_player = $"Girl Player"
@onready var video_spawn_point = $VideoWatchingSpawn

func _ready() -> void:
	if SpawnManager.spawn_name == "girl":
		girl_player.global_position = video_spawn_point.global_position
		SpawnManager.spawn_name = ""
