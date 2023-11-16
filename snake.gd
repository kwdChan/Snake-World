extends Node2D

var __grid_margin: float

# in pixel
var __grid_size: int

# x and y size (number of grids)
var __world_size: Vector2i

var __world_offset_pix: Vector2

var _action_intervel = 0.1

var _action_plan: Object

func _ready():
	$SnakeActionTimer.start()


func initialise(
		grid_size, 
		world_size, 
		grid_margin, 
		world_offset_pix, 
		initial_grid = Vector2(0, 0), 
	):
	"""
	Should be called immediately after the scene is created
	"""
	__grid_size = grid_size
	__world_size = world_size
	__grid_margin = grid_margin
	__world_offset_pix = world_offset_pix
	$SnakeNode.initialise(
		grid_size, 
		world_size, 
		grid_margin, 
		world_offset_pix, 
		initial_grid, 
	)
	
	
func use_action_plan(PlanClass):

	_action_plan = PlanClass.new()
	add_child(_action_plan)

	
func _on_snake_action_timer_timeout():
	
	if $SnakeNode:
		$SnakeNode.action(_action_plan.get_next_action(self))
		$SnakeActionTimer.set_wait_time(_action_intervel)
		$SnakeActionTimer.start()
	else: 
		queue_free()
	

	
