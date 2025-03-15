extends Node2D

var move_timer: Timer
var segments: Array[Vector2]
var apples: Array[Vector2]
var direction = Vector2(1, 0)
var next_direction = Vector2(1, 0)
var score = 0
var moving = false

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
	
	init_game()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_anything_pressed():
		if !moving:
			resume()
			
	if Input.is_action_just_pressed("ui_up") and direction != Vector2(0, 1):
		next_direction = Vector2(0, -1)
	elif Input.is_action_just_pressed("ui_down") and direction != Vector2(0, -1):
		next_direction = Vector2(0, 1)
	elif Input.is_action_just_pressed("ui_left") and direction != Vector2(1, 0):
		next_direction = Vector2(-1, 0)
	elif Input.is_action_just_pressed("ui_right") and direction != Vector2(-1, 0):
		next_direction = Vector2(1, 0)
		
	queue_redraw()

func _on_move_timer_timeout() -> void:
	direction = next_direction
	var head = segments.back()
	var new_head = head + direction
	
	if is_game_over(new_head):
		init_game()
		return
		
	var apple_index = get_point_index(new_head, apples)
	segments.append(new_head)
	
	if apple_index >= 0:
		score += 1
		place_apple(apple_index)
	else:
		segments.pop_front()
		
func init_game() -> void:
	pause()
	score = 0
	direction = Vector2(1, 0)
	next_direction = Vector2(1, 0)
	init_snake()
	init_apples()
	
func init_snake() -> void:
	segments = []
	var head = Vector2(ceil(Config.width/3), ceil(Config.height/2))
	var body = head - direction
	var tail = body - direction
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
		var x = apple.x * Config.cell_size
		var y = apple.y * Config.cell_size
		var size = Config.cell_size
		var rect = Rect2(x, y, size, size)
		draw_rect(rect, Config.apple_color)

func draw_grid() -> void:
	var grid_width = Config.cell_size * Config.width
	var grid_height = Config.cell_size * Config.height
	var rect = Rect2(0, 0, grid_width, grid_height)
	draw_rect(rect, Config.bg_color)
	
func draw_snake() -> void:
	for segment in segments:
		var x = segment.x * Config.cell_size
		var y = segment.y * Config.cell_size
		var size = Config.cell_size
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
