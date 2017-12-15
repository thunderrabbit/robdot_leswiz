extends Sprite

# colorset will be set of images soon
var colorset = [
	Color(0.962593, 0.499035, 0.517964), 
	Color(0.962593, 0.95568, 0.517964), 
	Color(0.484998, 0.95568, 0.517964), 
	Color(0.484998, 0.480191, 0.932654)
]

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func set_type_ordinal(my_type_ordinal):
	# set the color
	set_modulate(colorset[my_type_ordinal])
