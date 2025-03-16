extends Node

var width = 6
var height = 5
var cell_size = 64.0

var speed = 5.0

var num_apples = 5

var min_gap = 5.0
var max_gap = float(cell_size / 4)
var gap_step = 0.5

var bg_color = Color.BLACK
var snake_color = Color.WHITE
var apple_color = Color.RED

func _ready():
	pass
	
func _process(delta: float) -> void:
	var screen_height = get_viewport().size.y
	cell_size = screen_height / float(height)
