extends Node2D

const STATE_NORMAL = 0
const STATE_COMPLETED = 1

var _animation_player = null
var _state = STATE_NORMAL
var _value = 0
var _font = null


func _ready():
	_animation_player = get_node("AnimationPlayer")


func set_completed():
	if _state != STATE_COMPLETED:
		_animation_player.play("complete")
	_state = STATE_COMPLETED


func _draw():
	var value = str(_value)
	var size = _font.get_string_size(value)
	draw_string(_font, Vector2((20 - size.x) / 2, 10), \
		value, Color(1, 1, 1, 1))


func set_normal():
	if _state != STATE_NORMAL:
		_animation_player.play("normal")
	_state = STATE_NORMAL


func set_value(value, font):
	_value = value
	_font = font
