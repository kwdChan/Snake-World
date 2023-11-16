extends Node2D

# the number of grid
var WORLD_OFFSET_PIX = Vector2(50, 50)
var WORLD_SIZE = Vector2(100, 50)
# pixel size of the grids
var GRID_SIZE = 10
# snake scene
var SNAKE_SCENE := load("res://snake.tscn") as PackedScene
var GRID_MARGIN = 0.1

var RandomPlan := preload("res://snake_action_plan/random.gd")
var UserInputPlan := preload("res://snake_action_plan/user_input.gd")

func _ready():
	$SnakeSpawnTimer.start()
	new_snake(Vector2(10, 10))
	new_snake(Vector2(10, 10))

	new_snake().use_action_plan(UserInputPlan)
	draw_world_boundary()


func new_snake(loc=null):
	var snake = SNAKE_SCENE.instantiate()
	if not loc:
		loc = Vector2(
			randi_range(0, WORLD_SIZE.x-1), randi_range(0, WORLD_SIZE.y-1)
		)
	snake.initialise(
		GRID_SIZE,
		WORLD_SIZE, 
		GRID_MARGIN, 
		WORLD_OFFSET_PIX, 
		loc, 
	)
	add_child(snake)
	snake.use_action_plan(RandomPlan)
	return snake
	

func draw_world_boundary():
	$WorldBoundary.polygon = PackedVector2Array([
		WORLD_OFFSET_PIX + Vector2(0, 0), 
		WORLD_OFFSET_PIX + Vector2((WORLD_SIZE.x+1)*GRID_SIZE, 0), 
		WORLD_OFFSET_PIX + (WORLD_SIZE + Vector2.ONE) * GRID_SIZE, 
		WORLD_OFFSET_PIX + Vector2(0, (WORLD_SIZE.y+1)*GRID_SIZE), 
	])
	pass


func _on_snake_spawn_timer_timeout():
	$SnakeSpawnTimer.start()
	new_snake()

