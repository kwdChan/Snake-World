class_name Snake
extends Node2D

signal updated_node_positions(node_positions)

const SNAKE_SCENE := preload('res://snake_node.tscn') as PackedScene

var _action_intervel := 0.1

var _action_plan: Object

var _env: Types.Env

var nodes: Array[Types.SnakeNode] = []

var colour: Color:
	set(value):
		colour = value
		for node_ in nodes:
			node_.update_colour()

func _ready():
	$SnakeActionTimer.start()
	
func _process(_delta):
	if Input.is_action_just_pressed("ui_down"):
		nodes[0]._propergate_lengthen_signal()


func initialise(
		env, 
		initial_grid = Vector2(0, 0), 
		initial_colour = Color.from_hsv(0.5, 1, 1)
	):
	"""
	Should be called immediately after the scene is created
	"""
	_env = env 
	var new_node = SNAKE_SCENE.instantiate()
	colour = initial_colour
	print(initial_colour)
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
	
func _on_node_eaten(idx):
	if idx == 0:
		queue_free()
	
	nodes = nodes.filter(func (x): return (x.idx!=idx))

func add_new_node(new_node: Types.SnakeNode):
	nodes.append(new_node)
	
func _on_snake_action_timer_timeout():
	
	nodes[0].action(_action_plan.get_next_action(self))
	$SnakeActionTimer.set_wait_time(_action_intervel)
	$SnakeActionTimer.start()


func get_body_grids():
	
	var pos: Array[Vector2i] = []
	# TODO: safer to check if the node is valid
	for node_ in nodes:
		pos.append(node_.grid_pos)
		
	return pos

func _on_eat(obj: Object):
	print(obj)
	



func to_perspective(grids):
	var origin = nodes[0].grid_pos
	var rotation = Vector2(nodes[0].direction).angle_to(Vector2.UP)
	
	var transformed: Array[Vector2i] = []
	
	for i in range(len(grids)):
		var _temp = Vector2(grids[i] - origin).rotated(rotation)
		transformed.append(Vector2i(round(_temp)))
	
	return transformed

