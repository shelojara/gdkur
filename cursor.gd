extends Sprite


const INPUT_WAIT = 0.15
const WAIT_TIME = 0.2
const WAIT_TIME_PRESSED = 0.025


var _board = null
var _pos = Vector2()
var _wait = 0
var _pressed = false
var _origin = null
var _counter = null


func _ready():
	_board = get_parent().get_node("Board")
	_counter = get_node("Counter")

	set_process_input(true)
	set_process(true)


func _process(delta):
	_wait -= delta
	
	if _origin != null:
		_counter.show()
		var distance = _pos - _origin
		if distance.x > distance.y:
			_counter.set_text(str(distance.x + 1))
		else:
			_counter.set_text(str(distance.y + 1))
	else:
		_counter.hide()


func _move(x, y):
	if _board.is_pos_valid(_pos.x + x, _pos.y + y):
		_pos.x += x
		_pos.y += y

		var tile = _board.get_tile(_pos)
		set_pos(tile.get_pos())


func _input(event):
	# get release and dewait.
	if event.is_action_released("ui_left"):
		_dewait()
	elif event.is_action_released("ui_right"):
		_dewait()
	elif event.is_action_released("ui_down"):
		_dewait()
	elif event.is_action_released("ui_up"):
		_dewait()

	# move press and hold.
	elif event.is_action("ui_left"):
		if _allow_action():
			_move(-1, 0)
	elif event.is_action("ui_right"):
		if _allow_action():
			_move(1, 0)
	elif event.is_action("ui_down"):
		if _allow_action():
			_move(0, 1)
	elif event.is_action("ui_up"):
		if _allow_action():
			_move(0, -1)
	
	# mark and fill.
	elif event.is_action_pressed("btn_mark"):
		_board.get_tile(_pos).mark()
		_board.update(_pos.x, _pos.y)
	elif event.is_action_pressed("btn_fill"):
		_board.get_tile(_pos).fill()
		_board.update(_pos.x, _pos.y)
	elif event.is_action_pressed("btn_count"):
		if _origin != null:
			_origin = null
		else:
			_origin = _pos

func _dewait():
	_pressed = false
	_wait = 0


func _allow_action():
	if _wait <= 0:
		if _pressed:
			_wait = WAIT_TIME_PRESSED
		else:
			_wait = WAIT_TIME
			_pressed = true
		return true
	else:
		return false
