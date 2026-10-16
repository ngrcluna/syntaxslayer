extends Node

var db: SQLite

func _ready() -> void:
	db = SQLite.new()
	db.path = "user://game_data.db"
	db.verbosity_level = SQLite.NORMAL
	db.foreign_keys = true
	if not db.open_db():
		push_error("Could not open database: " + db.error_message)
		return
	_create_tables()
	_seed_questions()

func _create_tables() -> void:
	db.create_table("topics", {
		"id":     {"data_type": "text", "primary_key": true, "not_null": true},
		"name":   {"data_type": "text", "not_null": true},
		"advice": {"data_type": "text", "not_null": true}
	})
	db.create_table("questions", {
		"id":       {"data_type": "text", "primary_key": true, "not_null": true},
		"language": {"data_type": "text", "not_null": true},
		"stage":    {"data_type": "int",  "not_null": true},
		"topic_id": {"data_type": "text", "not_null": true},
		"text":     {"data_type": "text", "not_null": true}
	})
	db.create_table("choices", {
		"row_id":      {"data_type": "int",  "primary_key": true, "auto_increment": true, "not_null": true},
		"question_id": {"data_type": "text", "not_null": true},
		"choice_id":   {"data_type": "text", "not_null": true},
		"text":        {"data_type": "text", "not_null": true},
		"is_correct":  {"data_type": "int",  "default": 0}
	})
	db.create_table("attempts", {
		"id":       {"data_type": "int",  "primary_key": true, "auto_increment": true, "not_null": true},
		"language": {"data_type": "text", "not_null": true},
		"stage":    {"data_type": "int",  "not_null": true},
		"taken_at": {"data_type": "int",  "not_null": true}
	})
	db.create_table("attempt_answers", {
		"attempt_id":  {"data_type": "int",  "not_null": true},
		"question_id": {"data_type": "text", "not_null": true},
		"choice_id":   {"data_type": "text", "not_null": true},
		"correct":     {"data_type": "int",  "not_null": true}
	})

func _seed_questions() -> void:
	# Only seed once
	db.query("SELECT COUNT(*) AS n FROM questions")
	if db.query_result[0].n > 0:
		return

	db.insert_row("topics", {"id": "functions", "name": "Functions",
		"advice": "Review how to define and call functions with def."})
	db.insert_row("topics", {"id": "data_types", "name": "Data Types",
		"advice": "Practice the difference between int, float, str and bool."})

	_add_question("py_s1_q001", "python", 1, "functions",
		"Which keyword defines a function in Python?",
		["func", "def", "function", "fn"], 1)
	_add_question("py_s1_q002", "python", 1, "data_types",
		"What is the output of print(type(3.0))?",
		["int", "str", "float", "double"], 2)

func _add_question(id: String, lang: String, stage: int, topic: String,
		text: String, choices: Array, correct_index: int) -> void:
	db.insert_row("questions", {"id": id, "language": lang, "stage": stage,
		"topic_id": topic, "text": text})
	var letters = ["a", "b", "c", "d", "e", "f"]
	for i in choices.size():
		db.insert_row("choices", {
			"question_id": id,
			"choice_id": letters[i],
			"text": choices[i],
			"is_correct": 1 if i == correct_index else 0
		})

# ---------- Public API used by the scene ----------

func get_questions(language: String, stage: int) -> Array:
	db.query_with_bindings(
		"SELECT id, topic_id, text FROM questions WHERE LOWER(language) = LOWER(?) AND stage = ?",
		[language, stage])
	var rows = db.query_result.duplicate(true)
	var questions: Array = []
	for row in rows:
		db.query_with_bindings(
			"SELECT choice_id AS id, text FROM choices WHERE question_id = ? ORDER BY choice_id",
			[row.id])
		questions.append({
			"id": row.id,
			"topic": row.topic_id,
			"question": row.text,
			"choices": db.query_result.duplicate(true)
		})
	return questions

func is_correct(question_id: String, choice_id: String) -> bool:
	db.query_with_bindings(
		"SELECT is_correct FROM choices WHERE question_id = ? AND choice_id = ?",
		[question_id, choice_id])
	return db.query_result.size() > 0 and db.query_result[0].is_correct == 1

func get_advice(topic_id: String) -> String:
	db.query_with_bindings("SELECT advice FROM topics WHERE id = ?", [topic_id])
	return db.query_result[0].advice if db.query_result.size() > 0 else ""

func submit_attempt(attempt: Dictionary) -> void:
	db.query("BEGIN")
	db.query_with_bindings(
		"INSERT INTO attempts (language, stage, taken_at) VALUES (?, ?, ?)",
		[attempt.language, attempt.stage, attempt.timestamp])
	var attempt_id = db.last_insert_rowid
	for a in attempt.answers:
		db.query_with_bindings(
			"INSERT INTO attempt_answers (attempt_id, question_id, choice_id, correct) VALUES (?, ?, ?, ?)",
			[attempt_id, a.question_id, a.choice_id, 1 if a.correct else 0])
	db.query("COMMIT")

func _exit_tree() -> void:
	if db:
		db.close_db()
