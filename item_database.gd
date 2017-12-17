extends Node

const ITEM_NAME         = 0
const ITEM_SPRITE       = 3
const ITEM_TYPE         = 4


var item_database = [
	{
		ITEM_NAME : "Dog",
		ITEM_SPRITE : 0
	},
	{
		ITEM_NAME : "Cat",
		ITEM_SPRITE : 1
	},
	{
		ITEM_NAME : "Pig",
		ITEM_SPRITE : 2
	},
	{
		ITEM_NAME : "Sheep",
		ITEM_SPRITE : 3
	}
]

var item_map = { }

func _ready():
	for id in range(item_database.size()):
		item_map[item_database[id][ITEM_NAME]] = id

func get_item_id(name):
	return item_map[name]

func get_item_name(id):
	return item_database[id][ITEM_NAME]

func get_item_sprite(id):
	return item_database[id][ITEM_SPRITE]

func num_items():
	return item_database.size()


