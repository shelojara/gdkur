extends Sprite


const STATE_BLANK = 0
const STATE_FILLED = 1
const STATE_MARKED = 2


var _state = STATE_BLANK
var _animations = null


func _ready():
	_animations = get_node("AnimationPlayer")


func mark():
	if _state != STATE_MARKED:
		_animations.play("mark")
		_state = STATE_MARKED
	else:
		clear()


func fill():
	if _state != STATE_FILLED:
		_animations.play("fill")
		_state = STATE_FILLED
	else:
		clear()


func clear():
	_animations.play("blank")
	_state = STATE_BLANK


func is_filled():
	return _state == STATE_FILLED


func is_marked():
	return _state == STATE_MARKED


func is_blank():
	return _state == STATE_BLANK


func get_state():
	return _state
