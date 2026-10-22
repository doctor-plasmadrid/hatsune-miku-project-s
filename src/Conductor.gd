extends AudioStreamPlayer
class_name Conductor

var song_position: float = 0.0
var sec_per_beat: float
@export var bpm: float = 185.0

func _ready() -> void:
	sec_per_beat = 60.0 / bpm

func start_song() -> void:
	play()

func _process(_delta: float) -> void:
	if playing:
		song_position = get_playback_position() + AudioServer.get_time_since_last_mix()
		song_position -= AudioServer.get_output_latency()
