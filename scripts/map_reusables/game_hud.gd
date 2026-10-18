extends CanvasLayer


func _ready() -> void:
	var bag := get_node_or_null("/root/BagHud")
	if bag:
		bag.bag_menu.opened.connect(func(): visible = false)
		bag.bag_menu.closed.connect(func(): visible = true)
