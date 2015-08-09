extends Node2D

var _enable_time = 0
var _destination = null
var _mouse_over = false
var _mouse_click = false
var _path = null
var _load_call = null


func _ready():
	set_process(true)

	var area = get_node("Area2D")
	area.connect("mouse_enter", self, "_on_mouse_enter")
	area.connect("mouse_exit", self, "_on_mouse_exit")


func _process(delta):
	_enable_time -= delta

	if _enable_time <= 0:
		var position = get_pos()
		position += (_destination - position) * 0.1
		set_pos(position)

		var rotation = get_rot()
		rotation -= rotation * 0.1
		set_rot(rotation)

	if _mouse_over:
		if not _mouse_click and Input.is_action_pressed("mouse_click"):
			get_parent().get_parent().load_call(_load_call, _path)
			_mouse_click = true
		else:
			_mouse_click = false
	else:
		_mouse_click = false


func set_enable_time(time):
	_enable_time = time


func set_destination(destination):
	_destination = destination


func _on_mouse_enter():
	_mouse_over = true


func _on_mouse_exit():
	_mouse_over = false


func set_path(path):
	_path = path


func set_load_call(load_call):
	_load_call = load_call
