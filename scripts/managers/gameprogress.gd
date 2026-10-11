extends Node

signal tools_changed
signal door_unlocked(door_id: String)  
signal door_locked(door_id: String)
var current_language := "Python"
var current_stage := 1
var unlocked_doors := {} 
var completed_knowledge_scans = {}
var completed_videos = {}
var received_journal_compiler = {}
var completed_stages = {}
var completed_knowledge_checks = {}

var met_npc_intro := false

# Tools: global, collected once, kept for every language
var has_journal := false
var has_compiler := false

func unlock_door(door_id: String) -> void:
	if unlocked_doors.get(door_id, false):
		return
	unlocked_doors[door_id] = true
	door_unlocked.emit(door_id)

func is_door_unlocked(door_id: String) -> bool:
	return unlocked_doors.get(door_id, false)

func lock_door(door_id: String) -> void:
	if not unlocked_doors.get(door_id, false):
		return
	unlocked_doors[door_id] = false
	door_locked.emit(door_id)

func collect_tool(tool_name: String) -> void:
	match tool_name:
		"journal":
			has_journal = true
		"compiler":
			has_compiler = true

	if has_journal and has_compiler:
		var key = "%s_stage_%d" % [current_language, current_stage]
		received_journal_compiler[key] = true

	tools_changed.emit()
