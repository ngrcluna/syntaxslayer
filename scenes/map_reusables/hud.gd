extends CanvasLayer

@onready var hud_row: HBoxContainer = $HBoxContainer
@onready var bag_button: TextureButton = $HBoxContainer/BagButton
@onready var bag_menu = $BagMenu


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Gameprogress.hud_allowed_changed.connect(_on_hud_allowed_changed)
	Gameprogress.bag_changed.connect(refresh)
	bag_button.pressed.connect(_on_bag_pressed)
	visible = Gameprogress.hud_allowed
	refresh()


func _on_bag_pressed() -> void:
	if bag_menu.visible:
		bag_menu.close()
	else:
		bag_menu.open()


func _on_hud_allowed_changed(allowed: bool) -> void:
	visible = allowed
	refresh()


func refresh() -> void:
	hud_row.visible = Gameprogress.hud_allowed
	bag_button.visible = Gameprogress.has_bag
	if not Gameprogress.hud_allowed and bag_menu.visible:
		bag_menu.close()
