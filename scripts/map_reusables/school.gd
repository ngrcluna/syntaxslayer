extends Node2D

func _ready() -> void:
	for zone in get_tree().get_nodes_in_group("bug_zones"):
		if Gameprogress.is_bug_zone_cleared(zone.name):
			zone.queue_free()
