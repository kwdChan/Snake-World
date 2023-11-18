class_name Snake
extends Node2D

signal updated_node_positions(node_positions)

const SNAKE_SCENE := preload('res://snake_node.tscn') as PackedScene

var _action_intervel := 0.1

var _action_plan: Object

var _env: Types.Env

var nodes: Array[Types.SnakeNode] = []

var node_positions = []

var max_idx: int = -1

func _ready():
	$SnakeActionTimer.start()
	
func _process(_delta):
	if Input.is_action_just_pressed("ui_down"):
		nodes[0]._propergate_lengthen_signal()


func initialise(
		env, 
		initial_grid = Vector2(0, 0), 
	):
	"""
	Should be called immediately after the scene is created
	"""
	_env = env 
	var new_node = SNAKE_SCENE.instantiate()
	new_node.initialise(
		self, 
		env, 
		initial_grid, 
	)
	nodes.append(new_node)
	add_child(new_node)

	
func use_action_plan(PlanClass):

	_action_plan = PlanClass.new()
	add_child(_action_plan)
	

func lengthen():
	pass
	
func _on_node_hit(idx):
	if idx == 0:
		queue_free()

func _on_snake_action_timer_timeout():
	
	nodes[0].action(_action_plan.get_next_action(self))
	$SnakeActionTimer.set_wait_time(_action_intervel)
	$SnakeActionTimer.start()

func _on_node_update_position(idx, grid):
	
	if idx == max_idx+1:
		node_positions.append(grid)
	elif idx < max_idx+1:
		node_positions[idx] = grid
	else: 
		print('error')
	
	max_idx = max(max_idx, idx)


func to_perspective(grids):
	var origin = nodes[0].grid_pos
	var rotation = Vector2(nodes[0].direction).angle_to(Vector2.UP)
	
	var transformed: Array[Vector2i] = []
	
	for i in range(len(grids)):
		var _temp = Vector2(grids[i] - origin).rotated(rotation)
		transformed.append(Vector2i(round(_temp)))
	
	return transformed

