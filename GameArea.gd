extends Popup

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

const SLOT_SIZE = 52

class Slot:
	extends Control
	var container = null
	var stack     = null
	var menu      = null
	var dragging  = null
	var timer     = null
	var ItemDatabase
	
	func _init(c):
		container = c
	
	func _ready():
		ItemDatabase = get_node("/root/item_database")
		set_size(Vector2(SLOT_SIZE + 2, SLOT_SIZE + 2))
	
	func _draw():
		draw_rect(Rect2(Vector2(0, 0), get_size()), Color(0.2, 0.2, 0.2, 1))
	
	func _input_event(event):
		if event.type == InputEvent.MOUSE_BUTTON:
			if event.button_index == 2:
				print(get_pos())
				show_menu(get_global_transform().get_origin() + event.pos)
				accept_event()
			elif event.button_index == 1:
				if !event.pressed:
					show_menu(get_global_transform().get_origin() + event.pos)
					accept_event()
	
	func update_contents():
		container.on_Update_inventory_contents()
		if stack != null:
			set_tooltip(ItemDatabase.get_item_name(stack.item))
			stack.set_size(Vector2(SLOT_SIZE, SLOT_SIZE))
			stack.set_pos(Vector2(1, 1))
			stack.layout()
		else:
			set_tooltip("")
	
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
		update_contents()
		return object
	
	func start_monitoring_drag(o):
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
		update_contents()
		return rv
	
	func get():
		return stack
	
	func set(s):
		if stack == null:
			stack = s
			add_child(stack)
			update_contents()
			return true
		return false
	
	func get_count():
		if stack == null:
			return 0
		else:
			return stack.count

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

