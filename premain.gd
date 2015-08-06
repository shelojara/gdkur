
extends Node2D

const LEVELS_DIR = "res://levels/"
const TITLE_PACKAGE = "Select a package"
const TITLE_LEVEL = "Select a level"

var BUTTON = preload("res://prefabs/button.scn")
var LEVEL = preload("res://main.scn")

var _buttons = null
var _title = null

func _ready():
	_buttons = get_node("Buttons")
	_title = get_node("Title")
	_title.set_text(TITLE_PACKAGE)

	var dir = Directory.new()
	dir.open(LEVELS_DIR)
	dir.list_dir_begin()
	
	var packages = []
	var file_name = dir.get_next()
	while file_name != "":
		if file_name != "." and file_name != "..":
			packages.append(file_name)
		file_name = dir.get_next()

	dir.list_dir_end()
	_place_buttons(LEVELS_DIR, packages, 0)


func _place_buttons(path_base, values, callback):
	var x = 80
	var y = 200
	var padding = 10
	var i = 0
	
	for value in values:
		var button = BUTTON.instance()

		# place.
		button.set_pos(Vector2(x, y))

		# set values.
		button.set_path(path_base + value)
		button.set_callback(callback)
		button.get_node("Label").set_text(value.split(".")[0])

		# advance position.
		i += 1
		if i % 7 != 0:
			x += 80 + padding

		else:
			x = 80
			y += 80 + padding

		_buttons.add_child(button)


func load_package(path):
	# remove all childs from _buttons.
	for child in _buttons.get_children():
		_buttons.remove_child(child)

	# list all files inside the package.
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()

	var levels = []
	var file_name = dir.get_next()
	while file_name != "":
		if file_name != "." and file_name != "..":
			levels.append(file_name)
		file_name = dir.get_next()

	dir.list_dir_end()

	# place buttons.
	_place_buttons(path + "/", levels, 1)


func load_next(what, path):
	if what == 0:
		load_package(path)
	elif what == 1:
		load_level(path)


func load_level(path):
	var level = LEVEL.instance()
	level.get_node("Board").level = path
	var current = get_node("/root/World")
	current.queue_free()
	get_tree().get_root().add_child(level)
