extends CanvasLayer

@export var npc_node: Node2D  
@export var offset_above_head := Vector2(0, -60) 
 
# FONT AUTO-SIZE SETTINGS
@export var max_font_size := 32
@export var min_font_size := 16

func _process(_delta: float) -> void:
	if talking and npc_node:
		update_bubble_position()

func update_bubble_position() -> void:
	var cam = get_viewport().get_camera_2d()
	if cam:
		var world_pos = npc_node.global_position + offset_above_head
		var viewport_size = get_viewport().get_visible_rect().size
		var screen_pos = (world_pos - cam.global_position) * cam.zoom + viewport_size / 2
		speech_bubble.position = screen_pos
# ============================================================
# UI REFERENCES
# ============================================================
@onready var speech_bubble = $SpeechBubble
@onready var dialogue_text = $SpeechBubble/DialogueText
@onready var tap_button = $TapButton


# ============================================================
# DIALOGUE STATE
# ============================================================

var dialogue = []
var dialogue_index = 0
var talking = false


# ============================================================
# NPC GAME STATE
# ============================================================

var npc_state = "first_visit"


# Possible states:
#
# first_visit
# pre_assessment_complete
# journal_complete
# school_complete
# post_assessment_complete


# ============================================================
# READY
# ============================================================

func _ready() -> void:

	speech_bubble.hide()
	tap_button.hide()


# ============================================================
# START NPC DIALOGUE
# ============================================================

func start_dialogue() -> void:

	if talking:
		return

	talking = true
	dialogue_index = 0

	set_dialogue()

	speech_bubble.show()
	tap_button.show()

	set_dialogue_text(dialogue[dialogue_index])

func set_dialogue_text(text: String) -> void:
	dialogue_text.text = text

	var font = dialogue_text.get_theme_font("font")
	var box_size = speech_bubble.size
	var font_size = max_font_size

	while font_size > min_font_size:
		var text_size = font.get_multiline_string_size(
			text, HORIZONTAL_ALIGNMENT_CENTER, box_size.x, font_size
		)
		if text_size.y <= box_size.y:
			break
		font_size -= 1

	dialogue_text.add_theme_font_size_override("font_size", font_size)
# ============================================================
# SET DIALOGUE BASED ON GAME PROGRESS
# ============================================================

func set_dialogue() -> void:

	match npc_state:

		"first_visit":

			dialogue = [
				"Hey, Slayer! Welcome to Headquarters!",
				"Before you explore, we need to scan your programming knowledge.",
				"⮟ See the Knowledge Scanner on the left? Proceed there.",
				"And come back here. No pressure, just do your best!"
			]


		"pre_assessment_complete":

			dialogue = [
				"Scan complete! Here's something you'll need.",
				"This is your Journal. It contains video lessons you can watch anytime.",
				"Keep it with you. You'll need it on your journey."
			]


		"journal_complete":

			dialogue = [
				"Ready for your first mission?",
				"Something's wrong at the school. Programming bugs have been detected!",
				"Head there, investigate, and defeat the bugs."
			]


		"school_complete":

			dialogue = [
				"You're back! Nice work, Slayer.",
				"Let's see what you learned during your mission.",
				"Time for another Knowledge Scan."
			]


		"post_assessment_complete":

			dialogue = [
				"Scan complete! You've learned a lot.",
				"Review your Journal if you need to.",
				"More bugs are waiting for you!"
			]


		_:

			dialogue = [
				"Keep going, Slayer!",
				"Your next mission awaits."
			]


# ============================================================
# TAP TO CONTINUE
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


# ============================================================
# WHAT HAPPENS AFTER DIALOGUE
# ============================================================

func handle_dialogue_finished() -> void:

	match npc_state:

		"first_visit":
			print("Start Pre-Assessment")


		"pre_assessment_complete":
			print("Open Journal")


		"journal_complete":
			print("Start First Mission")


		"school_complete":
			print("Start Post-Assessment")


		"post_assessment_complete":
			print("Start Next Mission")

# ============================================================
# CHANGE GAME PROGRESS
# ============================================================

func complete_pre_assessment() -> void:
	npc_state = "pre_assessment_complete"


func complete_journal() -> void:
	npc_state = "journal_complete"


func complete_school_stage() -> void:
	npc_state = "school_complete"


func complete_post_assessment() -> void:
	npc_state = "post_assessment_complete"


func _on_scanner_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.play_lay_down_animation()
