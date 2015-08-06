
extends Node2D

var _path = null
var _mouse_over = false
var _callback = null

var _mouse_click = false
var _mouse_prev = false

func _ready():
	var area = get_node("Area2D")
	area.connect("mouse_enter", self, "_on_mouse_enter")
	area.connect("mouse_exit", self, "_on_mouse_exit")

	set_process(true)


func _process(delta):
	if _mouse_over:
		if not _mouse_click and Input.is_action_pressed("mouse_click"):
			get_parent().get_parent().load_next(_callback, _path)
			_mouse_click = true
		else:
			_mouse_click = false
	else:
		_mouse_click = false


func _on_mouse_enter():
	_mouse_over = true
	get_node("AnimationPlayer").play("over")


func _on_mouse_exit():
	_mouse_over = false
	get_node("AnimationPlayer").play("leave")


func set_path(path):
	_path = path


func set_callback(callback):
	_callback = callback