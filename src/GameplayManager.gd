extends Node2D

const HIT_WINDOWS = {
	"cool": 0.03,
	"fine": 0.07,
	"safe": 0.10,
	"sad": 0.15
}

var note_scene: PackedScene = preload("res://scenes/Note.tscn")
var approach_time: float = 2.0

var pending_notes: Array = []
var active_notes: Array[Node2D] = []

@onready var conductor = $Conductor
@onready var note_spawner = $NoteSpawner

func _ready() -> void:
	if not GameManager.current_song:
		GameManager.current_song = load("res://Game/SongResources/Mesmerizer.tres") 
		
	_load_chart_data()
	
	if GameManager.current_song.audio_stream:
		conductor.stream = GameManager.current_song.audio_stream
	
	conductor.finished.connect(_on_song_finished)
	
	conductor.start_song()

func _load_chart_data() -> void:
	if not GameManager.current_song or not GameManager.current_song.chart_file:
		push_error("No hay datos de canción cargados.")
		return
		
	var parsed_data = GameManager.current_song.chart_file.data
	
	if parsed_data is Array:
		for note in parsed_data:
			pending_notes.append({
				"time": float(note["time"]),
				"type": note["type"]
			})

func _process(_delta: float) -> void:
	if pending_notes.is_empty():
		return
		
	var current_time = conductor.song_position
	
	while pending_notes.size() > 0 and current_time >= pending_notes[0]["time"] - approach_time:
		var next_note_data = pending_notes.pop_front()
		_spawn_note_visual(next_note_data["time"], next_note_data["type"])

func _spawn_note_visual(target_time: float, type: String) -> void:
	var new_note = note_scene.instantiate()
	new_note.target_time = target_time
	new_note.spawn_time = target_time - approach_time
	new_note.type = type
	
	new_note.conductor = conductor
	new_note.track_curve = $TrackPath.curve 
	
	note_spawner.add_child(new_note)
	active_notes.append(new_note)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("note_up"):
		_evaluate_input("up")
	elif event.is_action_pressed("note_left"):
		_evaluate_input("left")
	elif event.is_action_pressed("note_down"):
		_evaluate_input("down")
	elif event.is_action_pressed("note_right"):
		_evaluate_input("right")

func _evaluate_input(note_type: String) -> void:
	var target_note = _get_next_active_note_of_type(note_type)
	if not target_note: 
		return
	
	var error_margin = abs(target_note.target_time - conductor.song_position)
	
	if error_margin <= HIT_WINDOWS["cool"]:
		_register_hit(target_note, "Cool")
	elif error_margin <= HIT_WINDOWS["fine"]:
		_register_hit(target_note, "Fine")
	elif error_margin <= HIT_WINDOWS["sad"]:
		_register_hit(target_note, "Sad")
	else:
		_register_miss(target_note)

func _get_next_active_note_of_type(note_type: String) -> Node2D:
	for note in active_notes:
		if note.type == note_type and not note.is_hit:
			return note
	return null

func _register_hit(note: Node2D, rating: String) -> void:
	print("Hit: ", rating)
	note.is_hit = true
	active_notes.erase(note)
	note.queue_free()

func _register_miss(note: Node2D) -> void:
	print("Miss!")
	note.is_hit = true
	active_notes.erase(note)
	note.queue_free()
	
func _on_song_finished() -> void:
	await get_tree().create_timer(2.0).timeout
	
	get_tree().change_scene_to_file("res://scenes/Menu.tscn")
