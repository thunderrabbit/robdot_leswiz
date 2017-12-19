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
