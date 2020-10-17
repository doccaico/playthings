extends Node2D

const SIM_WIDTH = 45
const SIM_HEIGHT = 45
const SIM_SIZE = SIM_WIDTH * SIM_HEIGHT 
# SIM_SIZE = 2025(45 * 45)
# about 708(0.35%) cell are alive
# if INITIAL_RANDOM_CELL = 0.2
# 405(0.2%) cell are alives
const INITIAL_RANDOM_CELL = 0.35
const ALIVE_COLOR = Color.green
const BACKGROUND_COLOR = Color.black
const SIM_CELL_SIZE = 10

var grid_visible = true
var sim_pause = true
var random_cells = []
var rectes = []
var board = [] # 1 is alive and 0 is dead

func _ready():
	VisualServer.set_default_clear_color(BACKGROUND_COLOR)
	OS.window_size = Vector2(SIM_WIDTH * SIM_CELL_SIZE, SIM_HEIGHT * SIM_CELL_SIZE)
	
	randomize()

	# initialize a board and rectes
	for i in range(1, SIM_SIZE + 1):
		random_cells.append(0 if i  > SIM_SIZE * INITIAL_RANDOM_CELL else 1)

	for y in range(SIM_HEIGHT):
		for x in range(SIM_WIDTH):
			board.append(0)
			var xpos = x * SIM_CELL_SIZE
			var ypos = y * SIM_CELL_SIZE
			var xsize = SIM_CELL_SIZE
			var ysize = SIM_CELL_SIZE
			rectes.append(Rect2(xpos, ypos, xsize, ysize))


func _physics_process(_delta):
	update()


func _process(_delta):
	update_input()


func _draw():

	if !sim_pause:
		print("next gene")
		next_generation()
	for i in range(SIM_SIZE):
		if board[i] == 1:
			draw_rect(rectes[i], ALIVE_COLOR)


func next_generation():
	var alive_neighbours = []
	for y in range(SIM_HEIGHT):
		for x in range(SIM_WIDTH):
			var n = [
					get_state(x - 1, y - 1), get_state(x, y - 1),
					get_state(x + 1, y - 1), get_state(x - 1, y),
					get_state(x + 1, y), get_state(x - 1, y + 1),
					get_state(x, y + 1), get_state(x + 1, y + 1)
					]
			var c = 0
			for i in n:
				if i == 1:
					c += 1
			alive_neighbours.append(c)

	for i in range(SIM_SIZE):
		match alive_neighbours[i]:
			2:
				pass
			3:
				board[i] = 1
			_:
				board[i] = 0


func get_state(x, y):
	if x < 0 || y < 0 || x >= SIM_WIDTH || y >= SIM_HEIGHT:
		return -1
	return board[x + y * SIM_WIDTH]


func clear():
	if !sim_pause:
		sim_pause = true
	for i in range(SIM_SIZE):
		board[i] = 0


func change_cell_state(position, state):
	var i = (floor(position.y) * SIM_WIDTH) + floor(position.x)
	board[i] = 1 if state else 0


func get_tile(x, y):
	x = floor(x)
	y = floor(y)
	if x < 0 || y < 0 || x >= SIM_WIDTH || y >= SIM_HEIGHT:
		return null
	return board[x + y * SIM_WIDTH]


func update_input():

	# z
	if Input.is_action_just_pressed("sim_grid"):
		grid_visible = !grid_visible
		if !grid_visible:
			$Grid.hide()
		else:
			$Grid.show()

	# x
	if Input.is_action_just_pressed("sim_pause"):
		
		for i in range(SIM_SIZE):
			if board[i] == 1:
				sim_pause = !sim_pause
				break

	# c
	if Input.is_action_just_pressed("sim_clear"):
		clear()

	# r
	if Input.is_action_just_pressed("sim_random"):
		random_cells.shuffle()
		board = random_cells.duplicate()

	# left click
	if Input.is_mouse_button_pressed(1):
		change_cell_state(get_viewport().get_mouse_position() / SIM_CELL_SIZE, true)

	# right click
	if Input.is_mouse_button_pressed(2):
		change_cell_state(get_viewport().get_mouse_position() / SIM_CELL_SIZE, false)
