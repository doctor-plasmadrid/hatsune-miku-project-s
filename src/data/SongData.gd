class_name SongData
extends Resource

@export var song_title: String = "Mesmerizer"
@export var artist: String = "32ki"
@export var cover_image: Texture2D

@export_group("Datos de Cantantes")
@export var default_modules: Array[ModuleData]

@export_group("Datos de Ritmo")
@export var bpm: float = 185.0
@export var audio_stream: AudioStream
@export var chart_file: JSON
