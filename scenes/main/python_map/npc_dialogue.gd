extends CanvasLayer

# ============================================================
# DIALOGUE STATE
# ============================================================

signal dialogue_finished
var dialogue = []
var dialogue_index = 0
var talking = false

# ============================================================
# NPC GAME STATE
# ============================================================

var npc_state = ""

@export var npc_node: Node2D
@export var offset_above_head := Vector2(0, -60)

# FONT AUTO-SIZE SETTINGS
@export var max_font_size := 28
@export var min_font_size := 16

# ============================================================
# NODES
# ============================================================

@onready var speech_bubble = $SpeechBubble
@onready var dialogue_text = $SpeechBubble/DialogueText
@onready var tap_button = $TapButton

# ============================================================
# PROCESS
# ============================================================

func _process(_delta: float) -> void:
	if talking and npc_node:
		update_bubble_position()

# ============================================================
# POSITION DIALOGUE BUBBLE
# ============================================================

func update_bubble_position() -> void:
	var cam = get_viewport().get_camera_2d()

	if cam:
		var world_pos = npc_node.global_position + offset_above_head
		var viewport_size = get_viewport().get_visible_rect().size

		var screen_pos = (
			world_pos - cam.global_position
		) * cam.zoom + viewport_size / 2

		speech_bubble.position = screen_pos

# ============================================================
# UPDATE NPC STATE BASED ON GAME PROGRESS
# ============================================================

func update_npc_state() -> void:

	var key = "%s_stage_%d" % [
		Gameprogress.current_language,
		Gameprogress.current_stage
	]

	# 1. Knowledge Scan has NOT been completed
	if not Gameprogress.completed_knowledge_scans.get(key, false):

		npc_state = "first_visit"

	# 2. Knowledge Scan is complete, but video is not
	elif not Gameprogress.completed_videos.get(key, false):

		npc_state = "pre_assessment_complete"

	# 3. Video is complete, but Journal + Compiler have not been received
	elif not Gameprogress.received_journal_compiler.get(key, false) and not (Gameprogress.has_journal and Gameprogress.has_compiler):
		npc_state = "journal_access"

	# 4. Journal + Compiler received, but stage is not complete
	elif not Gameprogress.completed_stages.get(key, false):

		npc_state = "journal_complete"

	# 5. Stage is complete, but Knowledge Check is not
	elif not Gameprogress.completed_knowledge_checks.get(key, false):

		npc_state = "school_complete"

	# 6. Everything for this stage is complete
	else:

		npc_state = "post_assessment_complete"

# ============================================================
# READY
# ============================================================

func _ready() -> void:

	speech_bubble.hide()
	tap_button.hide()

	# IMPORTANT:
	# Check GameProgress every time this scene loads
	update_npc_state()

# ============================================================
# START NPC DIALOGUE
# ============================================================

func start_dialogue() -> void:

	if talking:
		return

	# Always check the latest progress
	update_npc_state()

	talking = true
	dialogue_index = 0

	set_dialogue()

	speech_bubble.show()
	tap_button.show()

	set_dialogue_text(dialogue[dialogue_index])

# ============================================================
# AUTO-SIZE DIALOGUE TEXT
# ============================================================

func set_dialogue_text(text: String) -> void:

	dialogue_text.text = text

	var font = dialogue_text.get_theme_font("font")
	var box_size = speech_bubble.size
	var font_size = max_font_size

	while font_size > min_font_size:

		var text_size = font.get_multiline_string_size(
			text,
			HORIZONTAL_ALIGNMENT_CENTER,
			box_size.x,
			font_size
		)

		if text_size.y <= box_size.y:
			break

		font_size -= 1

	dialogue_text.add_theme_font_size_override(
		"font_size",
		font_size
	)

# ============================================================
# SET DIALOGUE BASED ON GAME PROGRESS
# ============================================================

func set_dialogue() -> void:

	match npc_state:

		# ====================================================
		# FIRST VISIT
		# ====================================================

		"first_visit":

			dialogue = [
				"Hey, Slayer! Welcome to Headquarters!",
				"Before you explore, we need to scan your programming knowledge.",
				"⮟ See the Knowledge Scanner on the left? Proceed there.",
				"And come back here. No pressure, just do your best!"
			]

		# ====================================================
		# AFTER KNOWLEDGE SCAN
		# ====================================================

		"pre_assessment_complete":

			dialogue = [
				"Scan complete! I need to show you something.",
				"Head to the computer in the room on the right ⮟",
				"Watch the video there. It'll teach you what you need to know.",
				"When you're finished, come back to me. I've got something for you that'll help you on your journey."
			]

		# ====================================================
		# AFTER VIDEO
		# ====================================================

		"journal_access":

			dialogue = [
				"Nice work!",
				"This is your journal and compiler on my desk ⮟",
				"Tap them to pick them up. You can open them anytime from the top right.",
				"Your compiler can help you test your code during battles."
			]

		# ====================================================
		# AFTER JOURNAL + COMPILER
		# ====================================================

		"journal_complete":

			dialogue = [
				"Ready for your first mission?",
				"Something's wrong at the school. Programming bugs have been detected!",
				"Head there, investigate, and defeat the bugs."
			]

		# ====================================================
		# AFTER STAGE
		# ====================================================

		"school_complete":

			dialogue = [
				"You're back! Nice work, Slayer.",
				"Let's see what you learned during your mission.",
				"Time for your Knowledge Check."
			]

		# ====================================================
		# AFTER KNOWLEDGE CHECK
		# ====================================================

		"post_assessment_complete":

			dialogue = [
				"Knowledge Check complete!",
				"Great job, Slayer.",
				"Review your Journal if you need to.",
				"More bugs are waiting for you!"
			]

		# ====================================================
		# DEFAULT
		# ====================================================

		_:

			dialogue = [
				"Keep going, Slayer!",
				"Your next mission awaits."
			]

# ============================================================
# TAP BUTTON
# ============================================================

func _on_tap_button_pressed() -> void:

	if not talking:
		return

	dialogue_index += 1

	if dialogue_index < dialogue.size():

		set_dialogue_text(dialogue[dialogue_index])

	else:

		end_dialogue()

# ============================================================
# END DIALOGUE
# ============================================================

func end_dialogue() -> void:

	talking = false

	speech_bubble.hide()
	tap_button.hide()

	handle_dialogue_finished()

	dialogue_finished.emit()

# ============================================================
# AFTER DIALOGUE
# ============================================================

func handle_dialogue_finished() -> void:

	match npc_state:

		"first_visit":
			print("Start Pre-Assessment")

		"pre_assessment_complete":
			print("Knowledge Scan Done")

		"journal_access":
			print("Journal and Compiler Unlocked")

		"journal_complete":
			print("Start Stage Mission")

		"school_complete":
			print("Start Knowledge Check")

		"post_assessment_complete":
			print("Start Next Stage")

# ============================================================
# CHANGE GAME PROGRESS
# ============================================================

func complete_pre_assessment() -> void:

	var key = "%s_stage_%d" % [
		Gameprogress.current_language,
		Gameprogress.current_stage
	]

	Gameprogress.completed_knowledge_scans[key] = true

	update_npc_state()


func complete_videowatching() -> void:

	var key = "%s_stage_%d" % [
		Gameprogress.current_language,
		Gameprogress.current_stage
	]

	Gameprogress.completed_videos[key] = true

	update_npc_state()


func complete_journal() -> void:

	var key = "%s_stage_%d" % [
		Gameprogress.current_language,
		Gameprogress.current_stage
	]

	Gameprogress.received_journal_compiler[key] = true

	update_npc_state()


func complete_school_stage() -> void:

	var key = "%s_stage_%d" % [
		Gameprogress.current_language,
		Gameprogress.current_stage
	]

	Gameprogress.completed_stages[key] = true

	update_npc_state()


func complete_post_assessment() -> void:

	var key = "%s_stage_%d" % [
		Gameprogress.current_language,
		Gameprogress.current_stage
	]

	Gameprogress.completed_knowledge_checks[key] = true

	update_npc_state()
