
extends CanvasLayer

@onready var fade_rect: ColorRect = $FadeRect

var is_transitioning := false


func _ready() -> void:
	fade_rect.modulate.a = 0.0


func change_scene(target_scene: String) -> void:
	if is_transitioning:
		return

	is_transitioning = true

	# Fade to black
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 0.5)
	await tween.finished

	# Change the scene
	get_tree().change_scene_to_file(target_scene)
	await get_tree().scene_changed

	# Fade back in
	var fade_tween = create_tween()
	fade_tween.tween_property(fade_rect, "modulate:a", 0.0, 0.4)
	await fade_tween.finished

	is_transitioning = false
