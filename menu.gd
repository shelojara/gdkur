extends Node2D

const LEVELS_DIR = "res://levels/"

var BLOCK = preload("res://menu/levelblock.scn")
var LEVEL = preload("res://main.scn")

var _blocks = null

func _ready():
	_blocks = get_node("Blocks")

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
	_place_buttons(LEVELS_DIR, packages, "levels")


func _place_buttons(path_base, values, load_call):
	var x = 90
	var y = 200
	var padding = 10
	var i = 0
	
	for value in values:
		var block = BLOCK.instance()

		# place.
		block.set_pos(Vector2(rand_range(100, 700), -50))
		block.set_destination(Vector2(x, y))
		block.set_rot(rand_range(0, 3.14))
		block.set_path(path_base + value)
		block.set_load_call(load_call)
		block.set_enable_time(i * 0.25)
		block.get_node("Label").set_text(value.split(".")[0])

		# advance position.
		i += 1
		if i % 7 != 0:
			x += 90 + padding

		else:
			x = 90
			y += 90 + padding

		_blocks.add_child(block)


func load_package(path):
	# remove all childs from _buttons.
	for child in _blocks.get_children():
		_blocks.remove_child(child)

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
	_place_buttons(path + "/", levels, "play")


func load_call(call, path):
	if call == "levels":
		load_package(path)

	elif call == "play":
		load_level(path)


func load_level(path):
	var level = LEVEL.instance()
	level.get_node("Board").level = path
	var current = get_node("/root/World")
	current.queue_free()
	get_tree().get_root().add_child(level)
