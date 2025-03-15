extends Node2D

@onready var hud: Control = $HUD
@onready var score_label: Label = $HUD/ScoreLabel
@onready var hud_background: ColorRect = $HUD/Background

var initial_direction = Vector2(1, 0)
var max_buffer_size = 2

var move_timer: Timer
var segments: Array[Vector2]
var apples: Array[Vector2]
var direction: Vector2
var input_buffer: Array[Vector2]
var score: int
var moving: bool

func _draw() -> void:
	draw_grid()
	draw_apples()
	draw_snake()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	move_timer = Timer.new()
	move_timer.wait_time = 1/Config.speed
	move_timer.autostart = false
	move_timer.one_shot = false
	move_timer.timeout.connect(_on_move_timer_timeout)
	add_child(move_timer)
	
	hud_background.color = Config.snake_color
	score_label.add_theme_color_override("font_color", Config.bg_color)
	
	init_game()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var grid_width = Config.cell_size * Config.width
	var screen_width = get_viewport_rect().size.x
	var screen_height = get_viewport_rect().size.y

	hud.position.x = grid_width
	hud.set_size(Vector2(screen_width - grid_width, screen_height))

	hud_background.set_size(hud.size)

	
	if Input.is_anything_pressed():
		if !moving:
			resume()
	
	var new_input = null
			
	if Input.is_action_just_pressed("ui_up"):
		new_input = Vector2(0, -1)
	elif Input.is_action_just_pressed("ui_down"):
		new_input = Vector2(0, 1)
	elif Input.is_action_just_pressed("ui_left"):
		new_input = Vector2(-1, 0)
	elif Input.is_action_just_pressed("ui_right"):
		new_input = Vector2(1, 0)
	
	if new_input != null and input_buffer.size() <= max_buffer_size:
		var last_input = direction if input_buffer.is_empty() else input_buffer.back()
		if new_input + last_input != Vector2.ZERO:
			input_buffer.append(new_input)
			
		
	queue_redraw()

func _on_move_timer_timeout() -> void:
	var new_direction = input_buffer.pop_front()
	if new_direction != null:
		direction = new_direction
	var head = segments.back()
	var new_head = head + direction
	
	if is_game_over(new_head):
		init_game()
		return
		
	var apple_index = get_point_index(new_head, apples)
	segments.append(new_head)
	
	if apple_index >= 0:
		score = score + 1
		update_score_label()
		place_apple(apple_index)
	else:
		segments.pop_front()
		
func init_game() -> void:
	pause()
	update_score_label()
	score = 0
	direction = initial_direction
	input_buffer = []
	init_snake()
	init_apples()
	
func init_snake() -> void:
	segments = []
	var head = Vector2(ceil(Config.width/3), ceil(Config.height/2))
	var body = head - initial_direction
	var tail = body - initial_direction
	segments.append(tail)
	segments.append(body)
	segments.append(head)
	
func init_apples() -> void:
	apples = []
	var first = Vector2(ceil(Config.width * 3/4), ceil(Config.height/2))
	apples.append(first)
	
func place_apple(index: int) -> void:
	var valid_positions: Array[Vector2] = []
	for row in range(Config.height):
		for col in range(Config.width):
			var in_snake = get_point_index(Vector2(col, row), segments) >= 0
			var in_apple = get_point_index(Vector2(col, row), apples) >= 0
			
			if !in_snake and !in_apple:
				valid_positions.append(Vector2(col, row))
	
	apples[index] = valid_positions.pick_random()

func draw_apples() -> void:
	for apple in apples:
		var gap = Config.min_gap
		var size = Config.cell_size - 2*gap
		var x = apple.x * Config.cell_size + gap
		var y = apple.y * Config.cell_size + gap
		var rect = Rect2(x, y, size, size)
		draw_rect(rect, Config.apple_color)

func draw_grid() -> void:
	var grid_width = Config.cell_size * Config.width
	var grid_height = Config.cell_size * Config.height
	var rect = Rect2(0, 0, grid_width, grid_height)
	draw_rect(rect, Config.bg_color)
	
func draw_snake() -> void:
	for index in range(segments.size()):
		draw_segment(index)

func draw_segment(index: int) -> void:
	var reversed_index = segments.size() - 1 - index
	var intended_gap = Config.min_gap + reversed_index*Config.gap_step
	var gap = intended_gap if intended_gap <= Config.max_gap else Config.max_gap
	var size = Config.cell_size - 2*gap
	var segment = segments[index]
	var x = segment.x * Config.cell_size + gap
	var y = segment.y * Config.cell_size + gap
	var rect = Rect2(x, y, size, size)
	draw_rect(rect, Config.snake_color)
	
func get_point_index(point: Vector2, targets: Array[Vector2]) -> int:
	for index in range(targets.size()):
		var target = targets[index]
		if target.x == point.x and target.y == point.y:
			return index
	return -1
	
func is_game_over(head: Vector2) -> bool:
	var outside_width = head.x >= Config.width or head.x < 0
	var outside_height = head.y >= Config.height or head.y < 0
	
	if outside_height or outside_width:
		return true
	
	var snake_overlap_index = get_point_index(head, segments)
	return snake_overlap_index >= 0
	
func pause() -> void:
	moving = false
	move_timer.stop()

func resume() -> void:
	moving = true
	move_timer.start()

func update_score_label() -> void:
	score_label.text = "Score: " + str(score)
