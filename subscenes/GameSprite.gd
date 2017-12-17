extends Sprite

# colorset will be set of images soon
var colorset = [
	Color(0.962593, 0.499035, 0.517964), 
	Color(0.962593, 0.95568, 0.517964), 
	Color(0.484998, 0.95568, 0.517964), 
	Color(0.484998, 0.480191, 0.932654)
]

##  these hardcoded items should be folded into item_database.gd
##  but I cannot seem to get it loaded here
##  so for now, just hardcode them.
var ICON_SIZE = 50   ## made up shit
var RAW_LENGTH = 60  # mad up shit
func get_size():
	return Vector2(50,60)   ### Made up shit should be based on global / item_database

var ItemDatabase		# Will know about pieces   I want this to be a singleton outside this Class

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	ItemDatabase = get_node("/root/item_database")
	pass

# Change my_type_ordinal to get different icons
func set_type_ordinal(my_type_ordinal):
	# set the color
    # use icon not color	set_modulate(colorset[my_type_ordinal])
	var icon = my_type_ordinal   # Fack figure out Database later	ItemDatabase.get_item_sprite(my_type_ordinal)
	set_pos(get_size()/2)
	set_scale(get_size()/ICON_SIZE)
	set_texture(preload("res://items.png"))
	set_region(true)
	set_region_rect(Rect2(ICON_SIZE * (icon % RAW_LENGTH), ICON_SIZE * (icon / RAW_LENGTH), ICON_SIZE, ICON_SIZE))
