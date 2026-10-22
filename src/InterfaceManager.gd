extends Control

@export var available_songs: Array[SongData]

@onready var cover_rect = $MarginContainer/MainSplit/LeftPanel/CoverRect
@onready var lbl_title = $MarginContainer/MainSplit/LeftPanel/LblTitle
@onready var lbl_bpm = $MarginContainer/MainSplit/LeftPanel/LblBPM
@onready var lbl_artist = $MarginContainer/MainSplit/LeftPanel/LblArtist
@onready var singers_list = $MarginContainer/MainSplit/LeftPanel/SingersList
@onready var song_list = $MarginContainer/MainSplit/RightPanel/SongList

@onready var module_popup = $ModulePopup
@onready var tab_container = $ModulePopup/TabContainer

@export var available_modules: Array[ModuleData]

var current_focused_song: SongData
var current_editing_slot: int = 0

func _ready() -> void:
	_populate_song_list()
	if song_list.get_child_count() > 0:
		song_list.get_child(0).grab_focus()

func _process(_delta: float) -> void:
	if not module_popup.visible:
		if Input.is_action_just_pressed("ui_L"):
			_open_module_selector(0)
			
	else:
		if Input.is_action_just_pressed("ui_L"):
			_change_tab(-1)
		elif Input.is_action_just_pressed("ui_R"):
			_change_tab(1)
		elif Input.is_action_just_pressed("ui_cancel"):
			module_popup.hide()
			if song_list.get_child_count() > 0:
				song_list.get_child(0).grab_focus()

func _change_tab(direction: int) -> void:
	var total_tabs = tab_container.get_tab_count()
	if total_tabs <= 1:
		return
		
	var next_tab = wrapi(tab_container.current_tab + direction, 0, total_tabs)
	tab_container.current_tab = next_tab
	
	var current_grid = tab_container.get_child(next_tab).get_child(0)
	if current_grid.get_child_count() > 0:
		current_grid.get_child(0).grab_focus()

func _open_module_selector(slot_index: int) -> void:
	current_editing_slot = slot_index
	module_popup.show()
	
	for child in tab_container.get_children():
		child.queue_free()
		
	var modules_by_char = {}
	for mod in available_modules:
		if not modules_by_char.has(mod.character):
			modules_by_char[mod.character] = []
		modules_by_char[mod.character].append(mod)
		
	for char_name in modules_by_char.keys():
		var scroll = ScrollContainer.new()
		scroll.name = char_name
		
		var grid = GridContainer.new()
		grid.columns = 4
		scroll.add_child(grid)
		
		for mod in modules_by_char[char_name]:
			var btn = Button.new()
			btn.text = mod.module_name
			btn.pressed.connect(_on_module_chosen.bind(mod))
			grid.add_child(btn)
			
		tab_container.add_child(scroll)
		
	if tab_container.get_child_count() > 0:
		var first_grid = tab_container.get_child(0).get_child(0)
		if first_grid.get_child_count() > 0:
			first_grid.get_child(0).grab_focus()

func _on_module_chosen(selected_module: ModuleData) -> void:
	current_focused_song.default_modules[current_editing_slot] = selected_module
	_on_song_focused(current_focused_song)
	module_popup.hide()
	song_list.get_child(0).grab_focus()

func _populate_song_list() -> void:
	for song in available_songs:
		var btn = Button.new()
		btn.text = song.song_title
		
		btn.focus_entered.connect(_on_song_focused.bind(song))
		btn.pressed.connect(_start_gameplay.bind(song))
		
		song_list.add_child(btn)

func _on_song_focused(song: SongData) -> void:
	current_focused_song = song
	cover_rect.texture = song.cover_image
	lbl_title.text = "Name: " + song.song_title
	lbl_bpm.text = "BPM: " + str(song.bpm)
	lbl_artist.text = "Artist: " + song.artist
	
	for child in singers_list.get_children():
		child.queue_free()
		
	for module in song.default_modules:
		var lbl = Label.new()
		lbl.text = module.character
		lbl.add_theme_color_override("font_color", module.character_color)
		singers_list.add_child(lbl)

func _start_gameplay(song: SongData) -> void:
	GameManager.load_song_defaults(song)
	get_tree().change_scene_to_file("res://scenes/Gameplay.tscn")
