extends Node

var width = 10
var height = 9
var cell_size = 64

var speed = 5.0

var num_apples = 1

var bg_color = Color.BLACK
var snake_color = Color.WHITE
var apple_color = Color.RED

func _ready():
	pass
	
func _process(delta: float) -> void:
	var screen_height = get_viewport().size.y
	cell_size = screen_height / float(height)
