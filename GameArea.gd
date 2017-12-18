extends Popup

#export(int)    var grid_slots  (was size)    = 5
var slots_across = 7		# game width in slots
var slots_down = 10		# game width in slots
var grid_slots      = slots_across * slots_down
var top_space = 30		# Might just move the Popup down instead
var left_space = 10		# Space on the left
var slot_gap = 5
var slot_gap_v = slot_gap
var slot_gap_h = slot_gap

# var bottom_space = 20

var player_sprite_y_shadow		# player's block sprite and shadow (where sprite would land)
var player_position = Vector2()	# player position in x,y index

var ItemDatabase		# Will know about pieces
var block_sprite = preload("res://SubScenes/GamePiece.tscn")

var column_heights = []	# how tall is each column?
var board = {}			# board of slots_across x slots_down
var slots = []			# array of all the (visual) positions in the board
var slottyMcSlotface	# Will be used to determine positions of pieces based on slots

var input_x_direction	# -1 = left; 0 = stay; 1 = right
var input_y_direction	# -1 = down; 0 = stay; 1 = up, but not implemented

const SLOT_SIZE = 52

class Slot:
	extends Control
	var container = null
	var stack     = null
	##  http://www.gamefromscratch.com/post/2015/02/23/Godot-Engine-Tutorial-Part-6-Multiple-Scenes-and-Global-Variables.aspx
	var GLOBALtop_space = 30		# Might just move the Popup down instead
	var GLOBALleft_space = 10		# Space on the left
	var GLOBALslot_gap_v = 5
	var GLOBALslot_gap_h = 5
	var menu      = null
	var dragging  = null
	var timer     = null
	var ItemDatabase
	
	func _init(c):
		container = c
	
	func _ready():
		ItemDatabase = get_node("/root/item_database")
		set_size(Vector2(SLOT_SIZE, SLOT_SIZE))
	
	func _draw():
		draw_rect(Rect2(Vector2(0, 0), get_size()), Color(0.2, 0.2, 0.2, 1))
	
	func _input_event(event):
		if event.type == InputEvent.MOUSE_BUTTON:
			if event.button_index == 2:
				print(get_pos(), "button 2")
				accept_event()
			elif event.button_index == 1:
				print(get_pos(), "button 1")
				if !event.pressed:
					accept_event()
	
	func can_drop_data(p, v):
		return can_add_stack(v[1])
	
	func drop_data(p, v):
		if !add_stack(v[1]) && v[0].has_method("add_stack"):
			v[0].add_stack(remove())
			add_stack(v[1])
		v[0].stop_monitoring_drag()
	
	func get_drag_data(p):
		if stack == null:
			return null
		# drag data is an array containing
		# * the container (used to swap with the contents of the destination)
		# * the dragged stack 
		var object = [self, stack]
		remove_child(stack)

		# we have to monitor the drag operation, in case the drop operation
		# is not handled
		start_monitoring_drag(stack)
		stack = null
		return object
	
	func start_monitoring_drag(o):
		print("started dragon")
		if dragging != null:
			print("error, already dragging")
		dragging = o
		timer = Timer.new()
		add_child(timer)
		timer.connect("timeout", self, "monitor_drag")
		timer.set_wait_time(0.1)
		timer.start()
	
	func monitor_drag():
		# if mouse button is not pressed anymore, drag was not handled. Cancel it
		if dragging != null && !Input.is_mouse_button_pressed(1):
			stack = dragging
			add_child(stack)
			stack.set_size(Vector2(SLOT_SIZE, SLOT_SIZE))
			stack.set_pos(Vector2(1, 1))
			stack.layout()
			stop_monitoring_drag()
	
	func stop_monitoring_drag():
		if dragging == null:
			print("error, was not dragging")
		else:
			dragging = null
		if timer == null:
			print("error, lost timer")
		else:
			timer.stop()
			timer.queue_free()
			timer = null
	
	func can_add_stack(s):
		return stack == null || stack.can_stack(s)
	
	func add_stack(s):
		var rv
		if stack == null:
			stack = s
			add_child(stack)
			rv = true
		else:
			rv = stack.stack(s)
		return rv
	
	func get():
		return stack
	
	func set(s):
		if stack == null:
			stack = s
			add_child(stack)
			return true
		return false
	
	func get_count():
		if stack == null:
			return 0
		else:
			return stack.count

	func get_position_for_xy(x,y):
		return Vector2(GLOBALleft_space+(SLOT_SIZE + GLOBALslot_gap_h)*(x), 
					    GLOBALtop_space+(SLOT_SIZE + GLOBALslot_gap_v)*(y))

func _ready():
	slottyMcSlotface = Slot.new(self)
	ItemDatabase = get_node("/root/item_database")
	randomize()		# randomize seed
	popup()			# make scene visible
	draw_slots()
	reset_column_heights()
	setup_board()
	new_player()
	set_process(true)
	set_process_input(true)

# columns start at height = 0
# (no pieces in any column)
func reset_column_heights():
	for i in range(slots_across):
		column_heights.append(0)

# setup the board
func setup_board():
	# clear block sprites if existing
	var existing_sprites = get_node(".").get_children()
	for sprite in existing_sprites:
		# do not remove slots from board
		if "is_a_game_piece" in sprite:
			sprite.queue_free()

	board = {}
	for i in range(slots_across):
		for j in range(slots_down):
			board[Vector2(i, j)] = null

func draw_slots():
	var x
	var y
	for i in range(grid_slots):
		print("add slot ", i)
		var slot = Slot.new(self)
		slot.set_name("slot_"+str(i))
		add_child(slot)
		slots.append(slot)
		x = i%slots_across
		y = i/slots_across
		slot.set_pos(slottyMcSlotface.get_position_for_xy(x,y))

func stop_moving():
	input_x_direction = 0
	input_y_direction = 0

func _input(event):
	var move_left = event.is_action_pressed("move_left")
	var move_right = event.is_action_pressed("move_right")
	var move_down = event.is_action_pressed("move_down")
	var drop_down = event.is_action_pressed("drop_down")
	var stop_moving = not (Input.is_action_pressed("move_right") or 
						   Input.is_action_pressed("move_left") or
						   Input.is_action_pressed("move_down")
						  )

	if move_left:
		print("move left")
		input_x_direction = -1
	elif move_right:
		print("move right")
		input_x_direction = 1
	elif move_down:
		print("move down")
		input_y_direction = 1
	elif drop_down:
		print("drop down")
		input_y_direction = slots_down
	elif stop_moving:
		stop_moving()

func _process(delta):
	print(input_x_direction, ", ", input_y_direction)
	if check_movable(input_x_direction, input_y_direction):
		move_player(input_x_direction, input_y_direction)
	if input_x_direction:
		pass

func check_movable(x, y):
	if x == -1 or x == 1:
		# check border
		if player_position.x + x >= slots_across or player_position.x + x < 0:
			return false
		# check collision
		if board[Vector2(player_position.x+x, player_position.y)] != null:
			return false
		return true

# move player
func move_player(x, y):
	player_position.x += x
	player_position.y += y
	update_player_sprites(player_sprite_y_shadow)

# get a random number to choose the type
func random_type():
	return randi() % ItemDatabase.num_items()

# update player sprite display
func update_player_sprites(player_sprites):
	player_sprites[0].get_node("Sprite").set_pos(slottyMcSlotface.get_position_for_xy(player_position.x, player_position.y))
	player_sprites[1].get_node("Sprite").set_pos(slottyMcSlotface.get_position_for_xy(player_position.x, column_height(player_position.x)))   ## shadow
	player_sprites[1].get_node("Sprite").set_modulate(Color(1,1,1, 0.3))

func column_height(column):
	return slots_down - column_heights[column] - 1

# generate a new player
func new_player():
	# new player will be a random of four colors
	var new_player_type_ordinal = random_type()

	# select top center position
	player_position = Vector2(slots_across/2, 0)

	# instantiate a block
	player_sprite_y_shadow = []

	# instantiate four blocks for our player.  i is unused here
	for i in range(2):
		# instantiate a block
		var sprite = block_sprite.instance()

		# test talking to the sprite's script
		sprite.set_type_ordinal(new_player_type_ordinal)

		# keep it in player_sprites so we can find them later
		player_sprite_y_shadow.append(sprite)
		# add it to scene
		add_child(sprite)
#
	# now arrange the blocks making up this player in the right shape
	update_player_sprites(player_sprite_y_shadow)
#
#	# check game over
#	for block in get_player_block_positions():
#		if board[Vector2(block.x, block.y)] != null:
#			game_over()
#			return

## I really do not like having these work here, but they do not seem to work elsewhere
## I want mouse_enter and mouse_exit to be handled by the piece, not the game board.
## Plus, why the heck do these get triggered for each piece when they are here at the board level??
func _on_GameArea_mouse_enter():
	print("GameArea entered")

func _on_GameArea_mouse_exit():
	print("GameArea exit")