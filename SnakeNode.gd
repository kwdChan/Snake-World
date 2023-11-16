extends Area2D

# how much area should be filled
var __grid_margin: float
var __world_offset_pix: Vector2
# in pixel
var __grid_size: int 

# x and y size (number of grids)
var __world_size: Vector2i

# has child or parent?
var __has_child = false

# direction of movement
var __direction = Vector2i.UP

# used to propergate the action the children
var __next_actioncode = ''

# used to count the position 
var idx = 0

var grid_pos: Vector2i

var random_seed = randf()

var pending_lengthen = false

var parent: Object

# propergate to the downstream
signal performed_action(turn, move)
signal lengthening
signal eaten
signal updated_position (idx, grid)

func _ready():
	#parent = get_parent()
	pass

	
func initialise(
	grid_size, 
	world_size, 
	grid_margin, 
	world_offset_pix, 
	initial_grid=Vector2(0,0), 
	direction=Vector2.UP, 
	new_idx=0, 
	upstream=false
	):
	"""
	Should be called immediately after the scene is created
	"""
	__grid_size = grid_size
	__world_size = world_size
	__direction = direction
	__grid_margin = grid_margin
	__world_offset_pix = world_offset_pix
	
	grid_pos = initial_grid
	idx = new_idx

	if upstream: 
		upstream.performed_action.connect(_propergate_parent_action)
		upstream.lengthening.connect(_propergate_lengthen_signal)
		upstream.eaten.connect(_propergate_eaten_signal)
		parent = upstream.get_parent()
	else:
		parent = get_parent()
	__set_viz_size(__grid_size)
	

	updated_position.connect(
		parent._on_node_update_position
	)
	_update_position(grid_pos)

	

func __set_viz_size(grid_size):
	"""
	draw the body segment
	"""
	var half_inner_size = (__grid_size*(1-__grid_margin))/2

	$SnakeViz.polygon = PackedVector2Array([
		Vector2(-half_inner_size, -half_inner_size), 
		Vector2( half_inner_size, -half_inner_size), 
		Vector2( half_inner_size,  half_inner_size), 
		Vector2(-half_inner_size,  half_inner_size), 
	])


func action(actioncode: String):
	var new_direction: Vector2i

	if actioncode == 'up':
		new_direction = __direction
		
	elif actioncode == 'left':
		new_direction = Vector2i(__direction.y, -__direction.x)

	elif actioncode == 'right':
		new_direction = Vector2i(-__direction.y, __direction.x)
		
	elif actioncode == '':
		return
	else: 
		print('unknown action: ' + actioncode)
		return 
		
	var new_grid_pos = grid_pos + new_direction
	if is_grid_inbound(new_grid_pos):
		if pending_lengthen: 
			__lengthen()
			
		__direction = new_direction
		grid_pos = new_grid_pos
		_update_position(new_grid_pos)
		performed_action.emit(actioncode)
		

func _propergate_parent_action(actioncode):
	
	if __next_actioncode: 

		action(__next_actioncode)
	__next_actioncode = actioncode
	

func __lengthen():
	"""
	Add a child to this exact node
	"""
	pending_lengthen = false
	assert (__has_child == false)
	__has_child = true
	var scn := load('res://snake_node.tscn') as PackedScene
	var __child = scn.instantiate()
	__child.initialise(
		__grid_size, 
		__world_size, 
		__grid_margin, 
		__world_offset_pix, 
		grid_pos, 
		__direction, 
		idx+1, 
		self
	)
	__child.eaten.connect(_on_child_eaten)
	add_sibling(__child)

func _on_child_eaten():
	__has_child = false

func _propergate_lengthen_signal():
	"""
	Propergate the lengthen signal until the end
	"""
	if not __has_child:
		pending_lengthen = true
	else: 
		lengthening.emit()

func _propergate_eaten_signal():
	if __has_child:
		eaten.emit()
	updated_position.emit(idx, null)
	queue_free()

func grid2pix(grid):
	# TODO
	return __world_offset_pix + Vector2((Vector2i(1,1)+grid) * __grid_size)


func is_grid_inbound(grid):
	var inbound1 = (__world_size.x > grid.x) && (__world_size.y > grid.y)
	var inbound2 = (grid.x >= 0) && (grid.y >= 0)
	return (inbound1) && (inbound2)


func _on_collision(area):
	if idx < area.idx:
		area._propergate_eaten_signal()
		_propergate_lengthen_signal()
	elif (idx ==  area.idx) && random_seed > area.random_seed:
		area._propergate_eaten_signal()
		_propergate_lengthen_signal()
	else:

		return

func _update_position(grid):
	position = grid2pix(grid)
	updated_position.emit(idx, grid)
