extends Node2D

const STATE_BLANK = 0
const STATE_FILLED = 1
const STATE_MARKED = 2

var TILE = preload("res://prefabs/blank.scn")
var NUMBER = preload("res://prefabs/label_number.scn")

var width = 5
var height = 5
var sector = 5
var level = "res://levels/1/0.krk"
var offset = Vector2(0, 50)

var _camera = null
var _tile_size = null
var _board_size = null
var _cursor = null
var _matrix = null
var _matrix_left = null
var _matrix_top = null

# lists saving the indices.
var _top = []
var _left = []


var _font = load("res://numberfont.fnt")


class Set:
	var values = []

	func add(value):
		if value in values:
			return

		values.append(value)

	func contains(value):
		return value in values

	func to_list():
		return values

	func size():
		return values.size()


func _ready():
	set_process_input(true)
	_read_file()

	height = _left.size()
	
	# the width is the size of the longest list in the _top.
	width = 0

	for list in _top:
		if list.size() > width:
			width = list.size()

	# extend top rows to fill the width.
	for list in _top:
		for i in range(width - list.size()):
			list.append(-1)

	_camera = get_parent().get_node("Camera")
	_tile_size = TILE.instance().get_texture().get_size().x
	_board_size = _build_board()

	# preprocess the entir matrix.
	for x in range(width):
		for y in range(height):
			update(x, y)
	
	_camera.set_pos(_board_size / 2 - offset)




func _input(event):
	if event.type == InputEvent.MOUSE_BUTTON:
		if event.is_pressed():
			var pos = event.pos - _camera.get_camera_pos()
			pos += Vector2(20, 20) # no idea why...

			var tile_pos_x = int(pos.x / _tile_size)
			var tile_pos_y = int(pos.y / _tile_size)

			if is_pos_valid(tile_pos_x, tile_pos_y):
				var tile = _matrix[tile_pos_x][tile_pos_y]

				# check if this is correct tile.
				if tile.get_pos().x > pos.x:
					# not the correct tile!
					tile_pos_x -= 1

				# check if this is correct tile.
				if tile.get_pos().y > pos.y:
					# not the correct tile!
					tile_pos_y -= 1

				_matrix[tile_pos_x][tile_pos_y].fill()
			else:
				# check if the click was in the last tile.
				# TODO!!
				pass


func _build_matrix(width, height):
	_matrix = []

	for x in range(width):
		var column = []
		for y in range(height):
			column.append(null)
		_matrix.append(column)
	return _matrix


func _build_board():
	# create the top matrix.
	_matrix_top = _build_matrix(_top[0].size(), _top.size())
	for y in range(_top.size()):
		var pos_y = (_top.size() - y) * (- 20)

		for x in range(_top[0].size()):
			var value = _top[y][x]

			if value == -1:
				continue

			var padding_x = x / sector
			var pos_x = _tile_size * x + x + padding_x

			var number = NUMBER.instance()
			number.set_pos(Vector2(pos_x, pos_y))
			number.set_value(str(value), _font)

			_matrix_top[x][y] = number
			add_child(number)

	# create the left matrix.
	_matrix_left = _build_matrix(_left[0].size(), _left.size())
	for y in range(_left.size()):
		var padding_y = y / sector
		var pos_y = _tile_size * y + y + padding_y + 3

		for x in range(_left[0].size()):
			var value = _left[y][x]

			if value == -1:
				continue

			var pos_x = (x - _left[0].size()) * 20 - 10

			var number = NUMBER.instance()
			number.set_pos(Vector2(pos_x, pos_y))
			number.set_value(str(value), _font)

			_matrix_left[x][y] = number
			add_child(number)

	# create the main matrix.
	_matrix = _build_matrix(width, height)
	var size = Vector2()
	for x in range(width):
		# calculate the x's position.
		var padding_x = x / sector
		var pos_x = _tile_size * x + x + padding_x

		for y in range(height):
			# calculate the y's position.
			var padding_y = y / sector
			var pos_y = _tile_size * y + y + padding_y

			var tile = TILE.instance()
			tile.set_pos(Vector2(pos_x, pos_y))
			add_child(tile)

			size.x = pos_x + _tile_size
			size.y = pos_y + _tile_size

			_matrix[x][y] = tile
	return size


func _read_file():
	var file = File.new()
	file.open(level, File.READ)

	var reading_top = true
	while not file.eof_reached():
		var line = file.get_line()

		# skip this and change to reading left side.
		if line[0] == "=":
			reading_top = false
			continue

		var numbers = _get_numbers(line)

		if reading_top:
			_top.append(numbers)
		else:
			_left.append(numbers)


func _get_numbers(line):
	var raw_numbers = line.split("\t")
	var numbers = []

	for number in raw_numbers:
		if number == "":
			numbers.append(-1)
		else:
			numbers.append(int(number))

	return numbers


func update(col, row):
	update_col(col)
	update_row(row)


func update_col(x):
	var completed_indices = _get_completed_indices_col(x)

	var real_y = 0
	for y in range(_top.size()):
		if _top[y][x] != -1:
			if real_y in completed_indices:
				_matrix_top[x][y].set_completed()
			else:
				_matrix_top[x][y].set_normal()
			real_y += 1


func update_row(y):
	var completed_indices = _get_completed_indices_row(y)

	var real_x = 0
	for x in range(_left[0].size()):
		if _left[y][x] != -1:
			if real_x in completed_indices:
				_matrix_left[x][y].set_completed()
			else:
				_matrix_left[x][y].set_normal()
			real_x += 1


func _get_completed_indices_col(x):
	"""
	Returns the completed indices for a given column
	of the puzzle in order to show that information to the player.
	"""
	var column = _get_col(x)
	var types_groups = _get_groups_col(x)
	var types = types_groups[0]
	var groups = types_groups[1]

	return _get_completed_indices(column, types, groups)


func _get_completed_indices_row(y):
	"""
	Returns the completed indices for a given column
	of the puzzle in order to show that information to the player.
	"""
	var row = _get_row(y)
	var types_groups = _get_groups_row(y)
	var types = types_groups[0]
	var groups = types_groups[1]

	return _get_completed_indices(row, types, groups)


func _get_completed_indices(expected, types, groups):
	"""
	Returns the completed indices for a column/row.
	"""
	var indices = Set.new()
	var used_groups = Set.new()

	# do nothing if the row/column is cero.
	if expected[0] == 0 and not STATE_FILLED in types:
		return [0]


	# check if the values are the exact same as the expected.
	var filled_only = []
	var filled_indices = []
	var real_i = 0
	for x in range(types.size()):
		if types[x] == STATE_FILLED:
			filled_indices.append(real_i)
			filled_only.append(groups[x])
			real_i += 1

	if expected == filled_only:
		return filled_indices

	# if the filled are more than expected, quit!
	if filled_only.size() > expected.size():
		return []

	# first, try from the left to the right.
	var filled_group_i = -1
	for i in range(groups.size()):
		var type = types[i]
		if type == STATE_BLANK:
			# if the state is blank, don't try more.
			break

		elif type == STATE_FILLED:
			filled_group_i += 1

			# add the group is at the same position of the values
			# group, then it is ok!, add it to the indices.
			var group = groups[i]
			if filled_group_i < expected.size() \
					and expected[filled_group_i] == group:
				indices.add(filled_group_i)
				used_groups.add(i)

	# now, right to left.
	filled_group_i = expected.size()
	for i in range(groups.size() - 1, -1, -1):
		if used_groups.contains(i):
			continue

		var type = types[i]
		if type == STATE_BLANK:
			# if the state is blank, don't try more.
			break

		elif type == STATE_FILLED:
			filled_group_i -= 1

			# add the group is at the same position of the values
			# group, then it is ok!, add it to the indices.
			var group = groups[i]
			if filled_group_i >= 0 \
					and expected[filled_group_i] == group:
				indices.add(filled_group_i)

	if indices.size() > expected.size():
		return []
	else:
		return indices.to_list()


func _get_col(x):
	"""
	Returns a list with the values of a column.
	"""
	var values = []
	for y in range(_top.size()):
		if _top[y][x] != -1:
			values.append(_top[y][x])
	return values


func _get_row(y):
	"""
	Returns a list with the values of a column.
	"""
	var values = []
	for x in range(_left[y].size()):
		if _left[y][x] != -1:
			values.append(_left[y][x])
	return values


func _get_groups_col(x):
	"""
	Organices the information of a column into groups, that is,
	4 of marks, 2 of filled, 5 blanks, etc...

	It returns a list with two values, the first is a list with the
	types of the groups and the second list in a list with the
	sizes of the groups.
	"""
	var actual_group = -1
	var types = []
	var groups = []

	for y in range(height):
		var tile = _matrix[x][y]
		if tile.get_state() != actual_group:
			actual_group = tile.get_state()
			types.append(tile.get_state())
			groups.append(1)
		else:
			groups[groups.size() - 1] += 1
	
	return [types, groups]


func _get_groups_row(y):
	"""
	Organices the information of a column into groups, that is,
	4 of marks, 2 of filled, 5 blanks, etc...

	It returns a list with two values, the first is a list with the
	types of the groups and the second list in a list with the
	sizes of the groups.
	"""
	var actual_group = -1
	var types = []
	var groups = []

	for x in range(width):
		var tile = _matrix[x][y]
		if tile.get_state() != actual_group:
			actual_group = tile.get_state()
			types.append(tile.get_state())
			groups.append(1)
		else:
			groups[groups.size() - 1] += 1

	return [types, groups]



func get_discrete_size():
	return Vector2(width, height)


func get_tile_size():
	return _tile_size


func get_tile(pos):
	return _matrix[pos.x][pos.y]


func is_pos_valid(x, y):
	return 0 <= x and x < width and 0 <= y and y < height
