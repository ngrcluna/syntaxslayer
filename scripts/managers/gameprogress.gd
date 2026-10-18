extends Node

# ---------------- SIGNALS ----------------
signal bag_changed
signal hud_allowed_changed(allowed: bool)
signal door_unlocked(door_id: String)
signal door_locked(door_id: String)
signal video_completed
signal mission_started_changed


var hud_allowed: bool = true:
	set(value):
		hud_allowed = value
		hud_allowed_changed.emit(value)

# ---------------- CONSTANTS ----------------
const LANGUAGES := ["Python", "C", "C++", "Java"]

# ---------------- CURRENT STATE ----------------
var current_language := "Python"
var current_stage := 1
var met_npc_intro := false
var mission_started := false

# ---------------- PROGRESS DATA ----------------
var unlocked_doors := {}
var completed_knowledge_scans := {}
var completed_videos := {}
var completed_stages := {}
var completed_knowledge_checks := {}

# ---------------- BAG ----------------
# The bag is global: collected once, kept for every language.
var has_bag := false

# Per-language kit (profile stays global; journal + map are per language)
var language_kits := {}   # { "Python": true }

# Compiler is global (works on every map), but each language's runner
# has to be built. Flip to true when we finish each one.
var compiler_ready := {
	"Python": true,
	"C": false,
	"C++": false,
	"Java": false,
}


# ---------------- DOORS ----------------
func is_door_unlocked(door_id: String) -> bool:
	return unlocked_doors.get(door_id, false)


func unlock_door(door_id: String) -> void:
	if unlocked_doors.get(door_id, false):
		return
	unlocked_doors[door_id] = true
	door_unlocked.emit(door_id)


func lock_door(door_id: String) -> void:
	if not unlocked_doors.get(door_id, false):
		return
	unlocked_doors[door_id] = false
	door_locked.emit(door_id)


# ---------------- BAG ----------------
func collect_bag() -> void:
	has_bag = true
	unlock_language_kit(current_language)  # emits bag_changed


func unlock_language_kit(language: String) -> void:
	language_kits[language] = true
	bag_changed.emit()


func has_kit(language := current_language) -> bool:
	return language_kits.get(language, false)


func is_compiler_ready(language: String) -> bool:
	return compiler_ready.get(language, false)


# ---------------- VIDEO ----------------
func stage_key(language := current_language, stage := current_stage) -> String:
	return "%s_stage_%d" % [language, stage]


func is_video_completed() -> bool:
	return completed_videos.get(stage_key(), false)


func complete_video() -> void:
	completed_videos[stage_key()] = true
	video_completed.emit()


# ---------------- STAGE PROGRESSION ----------------
func complete_stage(language := current_language, stage := current_stage) -> void:
	completed_stages[stage_key(language, stage)] = true


func is_first_stage_done(language: String) -> bool:
	return completed_stages.get(stage_key(language, 1), false)


# She must finish stage 1 of all four languages to progress.
func all_first_stages_done() -> bool:
	for lang in LANGUAGES:
		if not is_first_stage_done(lang):
			return false
	return true
