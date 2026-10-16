extends CanvasLayer

@onready var speech_bubble = $Dialogue/SpeechBubble
@onready var dialogue_text = $Dialogue/SpeechBubble/DialogueText
@onready var tap_button = $Dialogue/TapButton


# ============================================================
# DIALOGUE STATE
# ============================================================

var dialogue = []
var dialogue_index = 0
var talking = false

var npc_state = "first_visit"
# first_visit
# pre_assessment_complete
# journal_complete
# school_complete
# post_assessment_complete

func _ready() -> void:

	speech_bubble.hide()
	tap_button.hide()


# START NPC DIALOGUE
func start_dialogue() -> void:

	if talking:
		return

	talking = true
	dialogue_index = 0

	set_dialogue()

	speech_bubble.show()
	tap_button.show()

	dialogue_text.text = dialogue[dialogue_index]


# SET DIALOGUE BASED ON GAME PROGRESS

func set_dialogue() -> void:

	match npc_state:

		"first_visit":

			dialogue = [
				"Hey, Slayer! Welcome to Headquarters!",
				"Before you explore, we need to scan your programming knowledge.",
				"Complete the Knowledge Scan first. Just do your best!"
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

		dialogue_text.text = dialogue[dialogue_index]

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
