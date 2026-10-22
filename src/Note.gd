extends Node2D

var type: String = "left"
var target_time: float
var spawn_time: float
var approach_time: float = 2.0
var is_hit: bool = false

var conductor: AudioStreamPlayer
var track_curve: Curve2D
@onready var sprite = $Sprite2D

func _process(_delta: float) -> void:
	if is_hit or not conductor or not track_curve: 
		return
		
	var current_time = conductor.song_position
	var progress_ratio = (current_time - spawn_time) / approach_time
	
	var total_length = track_curve.get_baked_length()
	position = track_curve.sample_baked(total_length * progress_ratio)
	
	if current_time > target_time + 0.15: 
		get_parent().get_parent()._register_miss(self)
		
func _ready() -> void:
	var icon_path = "res://Game/NoteIcons/note_%s.png" % type
	
	var custom_texture = load(icon_path)
	
	if custom_texture:
		sprite.texture = custom_texture
	else:
		push_error("No se encontró la imagen en: " + icon_path)
