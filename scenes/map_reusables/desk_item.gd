extends Area2D

@export_enum("journal", "compiler") var item_id := "journal"
@export var item_texture: Texture2D


func _ready() -> void:
	$Sprite2D.texture = item_texture
	Gameprogress.tools_changed.connect(refresh)
	refresh()


func refresh() -> void:
	var key = "%s_stage_%d" % [
		Gameprogress.current_language,
		Gameprogress.current_stage
	]

	var video_done = Gameprogress.completed_videos.get(key, false)
	var owned = Gameprogress.has_journal if item_id == "journal" else Gameprogress.has_compiler

	visible = video_done and not owned
	input_pickable = visible


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not visible:
		return

	var tapped: bool = false

	if event is InputEventScreenTouch and event.pressed:
		tapped = true
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		tapped = true

	if tapped:
		visible = false
		input_pickable = false
		Gameprogress.collect_tool(item_id)
