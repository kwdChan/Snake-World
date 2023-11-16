extends Node2D

var __grid_margin: float

# in pixel
var __grid_size: int

# x and y size (number of grids)
var __world_size: Vector2i

var __world_offset_pix: Vector2

var _action_intervel = 0.1

var _action_plan: Object

var node_positions = []
var max_idx = -1

signal updated_node_positions(node_positions)

func _ready():
	$SnakeActionTimer.start()
	
func _process(delta):
	if Input.is_action_just_pressed("ui_down"):
		if $SnakeNode:
			$SnakeNode._propergate_lengthen_signal()

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

func lengthen():
	pass

func _on_snake_action_timer_timeout():
	
	if $SnakeNode:
		$SnakeNode.action(_action_plan.get_next_action(self))
		$SnakeActionTimer.set_wait_time(_action_intervel)
		$SnakeActionTimer.start()
	else: 
		queue_free()
	
func _on_node_update_position(idx, grid):
	
	if idx == max_idx+1:
		node_positions.append(grid)
	elif idx < max_idx+1:
		node_positions[idx] = grid
	else: 
		print('error')
	
	max_idx = max(max_idx, idx)
	#print(node_positions)
