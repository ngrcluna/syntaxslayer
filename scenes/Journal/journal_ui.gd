extends CanvasLayer

@onready var journal_icon: Button = $JournalButton
@onready var book: Control = $JournalBook
@onready var close_button: TextureButton = $JournalBook/CloseButton

func _ready() -> void:
	book.visible = false
	journal_icon.pressed.connect(open_journal)
	close_button.pressed.connect(close_journal)

func open_journal() -> void:
	book.visible = true
	journal_icon.visible = false

func close_journal() -> void:
	book.visible = false
	journal_icon.visible = true
