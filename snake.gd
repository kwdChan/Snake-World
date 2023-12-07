class_name Snake
extends Node2D

signal updated_node_positions(node_positions)
signal dead(snake: Snake)

const SNAKE_SCENE := preload('res://snake_node.tscn') as PackedScene

# if idx is not 0, it means it is food 
var idx = 0

var _action_intervel := 0.1

var policy: Policy

var _env: Env

var nodes: Array[SnakeNode] = []

var action_pending := false 

var got_attacked := false

var just_ate := false

var colour: Color:
	set(value):
		colour = value
		for node_ in nodes:
			node_.update_colour()

func _ready():
	name = 'Snake'
	$SnakeActionTimer.set_wait_time(_action_intervel)
	$SnakeActionTimer.start()
	

func _process(_delta):

	if Input.is_action_just_pressed("ui_down"):

		# TODO: check if nodes[0] exists
		if not idx == 0:
			return 

		if not len(nodes):
			push_warning("zero len snake")
			return 
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

	new_node.initialise(
		self, 
		env, 
		initial_grid, 
	)
	nodes.append(new_node)
	add_child(new_node)

func as_food():
	idx = 100000000000000
	policy = null

func use_policy(_policy: Policy):
	policy = _policy
	policy.action_ready.connect(perform_action)
	#add_child(obj)
	$SnakeActionTimer.start()
	
func perform_action(actioncode:Types.Action):
	action_pending = false

	if not len(nodes):
		push_warning("zero-length snake: perform_action")
		return 
	nodes[0].action(actioncode)
	
func if_got_attacked():
	# for punishment 
	var to_return = got_attacked
	got_attacked = false
	return to_return

	
func _on_node_eaten(node_idx):
	if node_idx == 0:
		dead.emit(self)
		
		# let the policy knows it died
		nodes = []
		policy.step(self)
		
		queue_free()
	got_attacked = true
	

	nodes = nodes.filter(func (x): return (x.idx!=node_idx))
	
	## as food
	if not len(nodes):
		queue_free()

func add_new_node(new_node: SnakeNode):
	nodes.append(new_node)
	
func _on_snake_action_timer_timeout():
	if not policy: 
		return 
	
	if action_pending:
		#push_warning("action pending")
		$SnakeActionTimer.wait_time = 0.01
		$SnakeActionTimer.start()
		
	else: 
		action_pending = true
		policy.step(self)
		$SnakeActionTimer.wait_time = _action_intervel
		$SnakeActionTimer.start()

func get_edible_parts() -> Array[Vector2i]:
	if idx > 0:
		return [get_head_grid()]
	else: 
		return get_body_grids()

func get_inedible_parts() -> Array[Vector2i]:
	if idx > 0:
		return get_body_grids()
	else: 
		return [get_head_grid()]
	
func get_head_grid() -> Vector2i:
	if not len(nodes):
		#push_warning("zero-length snake: get_head_grid")
		return Vector2i(0, 0)
		
	return nodes[0].grid_pos
	
func get_body_grids() -> Array[Vector2i]:
	
	var pos: Array[Vector2i] = []
	# TODO: safer to check if the node is valid
	var first = true
	for node_ in nodes:
		if first: 
			first = false
			continue
		pos.append(node_.grid_pos)   
	return pos

func _on_eat(obj: Object):
	just_ate = true
	var food_colour: Color = obj.get("colour")
	if food_colour:
		colour = Color.from_hsv(hue_avg(food_colour.h,  colour.h, 1, len(nodes)), 1, 1, 1)

func if_just_ate():
	var to_return = just_ate
	just_ate = false
	return to_return
		
func hue_avg(h1, h2, h1mag=1, h2mag=1):
	var new_angle = (Vector2.from_angle(h1*TAU)*h1mag + Vector2.from_angle(h2*TAU)*h2mag).angle()
	#print(rad_to_deg(new_angle))
	if new_angle <= 0:
		#print(new_angle/TAU)
		return  1 + (new_angle)/TAU
	else: 
		#print(new_angle/TAU)
		return new_angle/TAU
	

func to_perspective(grids: Array[Vector2i], to_rotate=true) -> Array[Vector2i]:
	if not len(nodes):
		#push_warning("zero len snake")
		return []
	var origin = nodes[0].grid_pos
	
	var _rotation = Vector2(nodes[0].direction).angle_to(Vector2.UP) if to_rotate else 0
	
	var transformed: Array[Vector2i] = []
	
	for i in range(len(grids)):
		var _temp = Vector2(grids[i] - origin).rotated(_rotation)
		transformed.append(Vector2i(round(_temp)))
	
	return transformed


	
func get_sensory_info() -> Dictionary:
	"""
	text to Array[Vector2i]
	"""
	return {
		body = to_perspective(get_body_grids()),
		no_go = to_perspective(_env.world_boundry_grids),
		edible = to_perspective(_env.get_edible_grids()),
		inedible = to_perspective(_env.get_inedible_grids()),
	}
