extends Area2D

@export var item_texture: Texture2D


func _ready() -> void:
	$Sprite2D.texture = item_texture
	Gameprogress.bag_changed.connect(refresh)
	refresh()


func refresh() -> void:
	var key = Gameprogress.stage_key()
	var video_done = Gameprogress.completed_videos.get(key, false)
	visible = video_done and not Gameprogress.has_bag
	input_pickable = visible


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not visible:
		return

	var tapped := false
	if event is InputEventScreenTouch and event.pressed:
		tapped = true
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		tapped = true

	if tapped:
		visible = false
		input_pickable = false
		Gameprogress.collect_bag()
