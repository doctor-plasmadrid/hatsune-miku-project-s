extends Node

var current_song: SongData
var active_modules: Array[ModuleData] = []

func load_song_defaults(song: SongData) -> void:
	current_song = song
	active_modules = song.default_modules.duplicate()
