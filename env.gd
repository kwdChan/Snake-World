class_name Env
extends Node2D

# world parameters 
const WORLD_PARAMS = {
	SIZE_GRID = Vector2(50, 50), 
	GRID_SIZE_PIX = 10,
	GRID_MARGIN = 0.1
}

# snake scene
const SNAKE_SCENE := preload("res://snake.tscn") as PackedScene

# action plans
const ACTION_PLANS = {
	Random = preload("res://snake_action_plan/random.gd"), 
	UserInput = preload("res://snake_action_plan/user_input.gd")
}

var all_snakes = []

func _ready():
	
	position = Vector2(20, 20)
	$SnakeSpawnTimer.start()

	new_snake().use_action_plan(ACTION_PLANS.UserInput)
	#new_snake(Vector2(10, 10))
	#new_snake(Vector2(10, 10))
	draw_world_boundary()


func new_snake(loc=null):
	var snake = SNAKE_SCENE.instantiate()
	if not loc:
		loc = Vector2(
			randi_range(0, WORLD_PARAMS.SIZE_GRID.x-1), randi_range(0, WORLD_PARAMS.SIZE_GRID.y-1)
		)
	snake.initialise(
		self, 
		loc, 
		Color.from_hsv(randf(), 1.0, 1.0, 1.0)
	)
	add_child(snake)
	snake.use_action_plan(ACTION_PLANS.Random)
	all_snakes.append(snake)
	
	return snake
	

func draw_world_boundary():
	$WorldBoundary.polygon = PackedVector2Array([
		Vector2(0, 0), 
		Vector2((WORLD_PARAMS.SIZE_GRID.x+1)*WORLD_PARAMS.GRID_SIZE_PIX, 0), 
		(WORLD_PARAMS.SIZE_GRID + Vector2.ONE) * WORLD_PARAMS.GRID_SIZE_PIX, 
		Vector2(0, (WORLD_PARAMS.SIZE_GRID.y+1)*WORLD_PARAMS.GRID_SIZE_PIX), 
	])



func _on_snake_spawn_timer_timeout():
	$SnakeSpawnTimer.start()
	new_snake()

	
func get_all_grids():
	var result = []
	all_snakes = all_snakes.filter(func(x):return is_instance_valid(x))
	for snake_ in all_snakes:
		result.append_array(snake_.get_body_grids())
	return result.filter(func(x): return (x != null))
	

