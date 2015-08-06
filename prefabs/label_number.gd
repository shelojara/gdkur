extends Label

const STATE_NORMAL = 0
const STATE_COMPLETED = 1

var _animation_player = null
var _state = STATE_NORMAL


func _ready():
	_animation_player = get_node("AnimationPlayer")


func set_completed():
	if _state != STATE_COMPLETED:
		_animation_player.play("complete")
	_state = STATE_COMPLETED


func set_normal():
	if _state != STATE_NORMAL:
		_animation_player.play("normal")
	_state = STATE_NORMAL
