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
const NO_POS := Vector2.INF

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
var language_kits := {}  

# Compiler is global (works on every map), true kapag tapos na
var compiler_ready := {
	"Python": true,
	"C": false,
	"C++": false,
	"Java": false,
}


# DOORS
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


# BAG
func collect_bag() -> void:
	has_bag = true
	unlock_language_kit(current_language)


func unlock_language_kit(language: String) -> void:
	language_kits[language] = true
	bag_changed.emit()


func has_kit(language := current_language) -> bool:
	return language_kits.get(language, false)


func is_compiler_ready(language: String) -> bool:
	return compiler_ready.get(language, false)


# VIDEO
func stage_key(language := current_language, stage := current_stage) -> String:
	return "%s_stage_%d" % [language, stage]


func is_video_completed() -> bool:
	return completed_videos.get(stage_key(), false)


func complete_video() -> void:
	completed_videos[stage_key()] = true
	video_completed.emit()


# STAGE PROGRESSION
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
	

# BUG ZONES
var bug_return_scene: String = ""
var bug_return_position: Vector2 = NO_POS
var bug_zone_id: String = ""
var current_question: Dictionary = {}

var cleared_bug_zones := {} # BugZone1 eme eme
var question_decks := {}    # Mga hindi pa nasasagutan
var bug_question_pool: String = "" # per zone questions

func start_bug_battle(scene_path: String, pos: Vector2, zone_id: String, pool := "") -> void:
	bug_return_scene = scene_path
	bug_return_position = pos
	bug_zone_id = zone_id
	bug_question_pool = pool
	current_question = draw_question()


func draw_question() -> Dictionary:
	var key := stage_key() + "/" + bug_question_pool
	if not question_decks.has(key) or question_decks[key].is_empty():
		question_decks[key] = Database.get_bug_questions(current_language, current_stage, bug_question_pool)
		question_decks[key].shuffle()
	if question_decks[key].is_empty():
		return {}
	return question_decks[key].pop_back()

func finish_bug_battle(won := true) -> void:
	if won:
		var key := stage_key()
		if not cleared_bug_zones.has(key):
			cleared_bug_zones[key] = []
		if bug_zone_id not in cleared_bug_zones[key]:
			cleared_bug_zones[key].append(bug_zone_id)
	FadeTransition.change_scene(bug_return_scene)


func is_bug_zone_cleared(zone_id: String) -> bool:
	return zone_id in cleared_bug_zones.get(stage_key(), [])
