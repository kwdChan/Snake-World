class_name SnakeNode
extends Area2D

## propergate to the downstream
signal performed_action(action: Types.Action)
signal lengthening
#signal updated_position (idx, grid)

## send to the upstream and snake
signal eaten(idx)

## send to snake
signal ate(obj: Object)

## count upstream (bad idea?)
var idx: int:
	get: 
		if _upstream: 
			return _upstream.idx +1 
		else: 
			return 0

## position and direction of movement
var direction: Vector2i
var grid_pos: Vector2i

## To deprecate
var random_seed = randf()

## lengthen happens as the node moves
var _pending_lengthen = false

## used to propergate the action the children
var _next_action := Types.Action.STAY

var _upstream: SnakeNode = null
var _downstream: SnakeNode = null

var _env: Types.Env 
var _snake: Types.Snake 


func initialise(
	snake: Types.Snake, 
	env: Types.Env, 
	initial_grid=Vector2(0,0), 
	initial_direction=Vector2.UP, 
	upstream=false
	):
	"""
	Should be called immediately after the scene is created
	"""
	_env = env
	_snake = snake 
	direction = initial_direction
	
	grid_pos = initial_grid

	if upstream: 
		upstream.performed_action.connect(_propergate_parent_action)
		upstream.lengthening.connect(_propergate_lengthen_signal)
		upstream.eaten.connect(_propergate_eaten_signal)
		_upstream = upstream

	__set_viz_size()
	
	eaten.connect(snake._on_node_eaten)
	ate.connect(snake._on_eat)
	_update_position(grid_pos)


func __set_viz_size():
	"""
	draw the body segment
	"""
	var half_inner_size = (_env.WORLD_PARAMS.GRID_SIZE_PIX * (1-_env.WORLD_PARAMS.GRID_MARGIN))/2

	$SnakeViz.polygon = PackedVector2Array([
		Vector2(-half_inner_size, -half_inner_size), 
		Vector2( half_inner_size, -half_inner_size), 
		Vector2( half_inner_size,  half_inner_size), 
		Vector2(-half_inner_size,  half_inner_size), 
	])


func action(actioncode: Types.Action):
	var new_direction: Vector2i

	if actioncode == Types.Action.UP:
		new_direction = direction
		
	elif actioncode == Types.Action.LEFT:
		new_direction = Vector2i(direction.y, -direction.x)

	elif actioncode == Types.Action.RIGHT:
		new_direction = Vector2i(-direction.y, direction.x)
		
	elif actioncode == Types.Action.STAY:
		return 
	else:
		push_error("Invalid Action")
		return 

	var new_grid_pos = grid_pos + new_direction
	if is_grid_inbound(new_grid_pos):
		if _pending_lengthen: 
			__lengthen()
			
		direction = new_direction
		grid_pos = new_grid_pos
		_update_position(new_grid_pos)
		performed_action.emit(actioncode)
		

func _propergate_parent_action(action: Types.Action):
	action(_next_action)
	_next_action = action


func __lengthen():
	"""
	Add a child to this exact node
	"""
	_pending_lengthen = false
	assert (not _downstream)

	var scn := load('res://snake_node.tscn') as PackedScene
	_downstream = scn.instantiate()
	_downstream.initialise(
		_snake, 
		_env, 
		grid_pos, 
		direction, 
		self
	)
	_downstream.eaten.connect(_on_child_eaten)
	_snake.add_new_node(_downstream)
	add_sibling(_downstream)
	

func _on_child_eaten(_idx):
	_downstream = null

func _propergate_lengthen_signal():
	"""
	Propergate the lengthen signal until the end
	"""
	if not _downstream:
		_pending_lengthen = true
	else: 
		lengthening.emit()

func _propergate_eaten_signal(_idx):

	eaten.emit(idx)
	#updated_position.emit(idx, null)
	queue_free()

func grid2pix(grid):
	# TODO
	return Vector2((Vector2i(1,1)+grid) * _env.WORLD_PARAMS.GRID_SIZE_PIX)


func is_grid_inbound(grid):
	var inbound1 = (_env.WORLD_PARAMS.SIZE_GRID.x > grid.x) && (_env.WORLD_PARAMS.SIZE_GRID.y > grid.y)
	var inbound2 = (grid.x >= 0) && (grid.y >= 0)
	return (inbound1) && (inbound2)


func _on_collision(area):
	if idx < area.idx:
		
		area._propergate_eaten_signal(idx)
		_propergate_lengthen_signal()
		ate.emit(area)
		
	elif (idx ==  area.idx) and (idx == 0):
		area._propergate_eaten_signal(idx)

	else:
		return

func _update_position(grid):
	position = grid2pix(grid)
	#updated_position.emit(idx, grid)
