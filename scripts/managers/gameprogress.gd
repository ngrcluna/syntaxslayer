extends Node

signal tools_changed

var current_language := "Python"
var current_stage := 1

var completed_knowledge_scans = {}
var completed_videos = {}
var received_journal_compiler = {}
var completed_stages = {}
var completed_knowledge_checks = {}

# Tools: global, collected once, kept for every language
var has_journal := false
var has_compiler := false


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
