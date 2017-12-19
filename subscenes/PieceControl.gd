extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	print("control is ready")

func _on_Control_input_event( ev ):
	print("_on_Control_input_event worked over here")


func _on_Control_mouse_exit():
	print("Kuni")
