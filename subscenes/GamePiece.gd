extends Area2D

# piece_type is more boss than the sprite node
var piece_type
var mouse_is_in
var is_a_game_piece = true

var typeset = [
	"dog",
	"cat",
	"pig",
	"sheep"
]

func set_type_ordinal(my_type_ordinal):
	piece_type = typeset[my_type_ordinal]
	get_node("Sprite").set_type_ordinal(my_type_ordinal)
	print("Hello I am a ", piece_type)
	pass

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _input_event(event):
	if event.type == InputEvent.MOUSE_BUTTON:
		if event.button_index == 2:
			print(self.get_slot_for_position(get_pos()), "button 2")

			if !event.pressed:
				print("not pressed")
		elif event.button_index == 1:
			print(self.get_slot_for_position(get_pos()), "button 1")
			if !event.pressed:
				print("not pressed")

	else:
		if event.type == InputEvent.MOUSE_MOTION:
			pass
		else:
			print("ddd")


func _on_Area2D_input_event( viewport, event, shape_idx ):
	print("_on_Area2D_input_event")

func _on_Area2D_mouse_enter():
	print("called mouse enter somehow")


func _on_Area2D_mouse_exit():
	print("called mouse exit")


func _on_Control_mouse_enter():
	print("it worked over here")