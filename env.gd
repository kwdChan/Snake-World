class_name Env
extends Node2D
signal snake_list_change

# world parameters 
const WORLD_PARAMS = {
	SIZE_GRID = Vector2(50, 50), 
	GRID_SIZE_PIX = 10,
	GRID_MARGIN = 0.1
}

# snake scene
const SNAKE_SCENE := preload("res://snake.tscn") as PackedScene

const ECO_PARAMS = {
	N_SNAKE = 10, 
	FOOD_INTERVAL = 1
}

# action plans
const ACTION_PLANS = {
	Random = preload("res://snake_action_plan/random.gd"), 
	UserInput = preload("res://snake_action_plan/user_input.gd")
}

var all_snakes: Array[Types.Snake] = []
var all_foods: Array[Types.Snake] = []

func get_all_foods() -> Array[Types.Snake]:
	all_foods = all_foods.filter(func(x):return is_instance_valid(x))
	return all_foods
	
func get_all_food_snake()-> Array[Types.Snake]:
	return get_all_foods() + get_all_snakes() 

func get_all_snakes() -> Array[Types.Snake]:
	all_snakes = all_snakes.filter(func(x):return is_instance_valid(x))
	return all_snakes
		

func _ready():
	
	$SnakeSpawnTimer.set_wait_time(ECO_PARAMS.FOOD_INTERVAL)
	$SnakeSpawnTimer.start()
	new_snake().use_action_plan(ACTION_PLANS.UserInput)
	for i in range(ECO_PARAMS.N_SNAKE-1):
		new_snake()
	draw_world_boundary()


func random_loc() -> Vector2:
	
	return Vector2(
			randi_range(0, WORLD_PARAMS.SIZE_GRID.x-1), randi_range(0, WORLD_PARAMS.SIZE_GRID.y-1)
		)

func new_snake(loc=null):
	var snake = SNAKE_SCENE.instantiate()
	if not loc:
		loc = random_loc()
	snake.initialise(
		self, 
		loc, 
		Color.from_hsv(randf(), 1.0, 1.0, 1.0)
	)
	add_child(snake)
	snake.use_action_plan(ACTION_PLANS.Random)
	all_snakes.append(snake)
	snake_list_change.emit()
	#snake.dead.connect(_on_snake_dead)
	return snake


	
func _on_snake_dead(_snake: Types.Snake):
	snake_list_change.emit()
	
func new_food(loc=null):
	var snake = SNAKE_SCENE.instantiate()
	if not loc:
		loc = random_loc()
	snake.initialise(
		self, 
		loc, 
		Color.from_hsv(randf(), 1.0, 1.0, 1.0)
	)
	snake.as_food()
	add_child(snake)

	all_foods.append(snake)
	return snake

func draw_world_boundary():
	$WorldBoundary.polygon = PackedVector2Array([
		Vector2(0, 0), 
		Vector2((WORLD_PARAMS.SIZE_GRID.x+1)*WORLD_PARAMS.GRID_SIZE_PIX, 0), 
		(WORLD_PARAMS.SIZE_GRID + Vector2.ONE) * WORLD_PARAMS.GRID_SIZE_PIX, 
		Vector2(0, (WORLD_PARAMS.SIZE_GRID.y+1)*WORLD_PARAMS.GRID_SIZE_PIX), 
	])


func _on_snake_spawn_timer_timeout():

	if len(all_snakes) < ECO_PARAMS.N_SNAKE:
		new_snake()
	new_food()
	$SnakeSpawnTimer.start()

func get_edible_grids() -> Array[Vector2i]:
	var result:Array[Vector2i] = []
	for food_snake_ in get_all_food_snake():
		result.append_array(food_snake_.get_edible_grids())
		
	return result

	
func get_inedible_grids() -> Array[Vector2i]:
	var result:Array[Vector2i] = []
	for food_snake_ in get_all_food_snake():
		result.append_array(food_snake_.get_inedible_grids())
		
	return result
	
	
	
func get_all_grids() -> Array[Vector2i]:
	var result:Array[Vector2i] = []
	for snake_ in get_all_food_snake():
		result.append_array(snake_.get_body_grids())
	return result
	

