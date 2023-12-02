class_name PolicyNearestFoodRecorded
extends NoStupidMove

var food_distance = 200
var ws_client: WSClient


@onready var id = str(get_instance_id())


var existing_pos: Vector2i

var existing_len: int
		
func use_ws_client(_ws_client:WSClient):
	ws_client = _ws_client
	ws_client.message_received.connect(_on_message)
	
	
func step(_snake):
	var data = _snake.get_sensory_info()
	var action = decide_what_action(_snake)
	
	
	# send to the python 
	# sensory info 
	
	# time (for delay monitoring)
	data['time'] = Time.get_ticks_msec()
	
	# rewards 
	var new_len = len(_snake.nodes) 
	var new_pos = _snake.nodes[0].grid_pos
	
	# there's one step delay before the snake knows it has eaten. so we have to detect it ourselves
	var food_closest_dist = (data['edible'].map(func(vec): return abs(vec.x)+abs(vec.y))).min()
	data['rewards'] = 0
	if (food_closest_dist == 0) and (new_pos != existing_pos):
		data['rewards'] = 1 
		
	# punishment
	data['rewards'] += min(new_len-existing_len, 0)
	existing_pos = new_pos
	existing_len = new_len
	
	# action 
	data['action'] = action
	
	ws_client.send(
		JSON.stringify(data), 
		"supervised",
		id
	)
	emit_signal("action_ready", action)
	
	
	
	
func decide_what_action(_snake) :
	

	var possible_moves = get_non_stupid_moves(_snake)
	var possible_moves_ = possible_moves.duplicate()
	var body_grids: Array[Vector2i] = _snake.get_body_grids()
	var edible_grids: Array[Vector2i] = _snake._env.get_edible_grids().filter(func(g): return (g not in body_grids))
	
	edible_grids = _snake.to_perspective(edible_grids)
	edible_grids = edible_grids.filter(func(g):return ((abs(g.x)+abs(g.y))<food_distance))
	
	var filter = func (grid):
		if (grid.x > 0) and (Action.RIGHT not in possible_moves):
			return false
		if (grid.x < 0) and (Action.LEFT not in possible_moves):
			return false
		if (grid.y > 0):
			return false
		if (grid.y < 0) and (Action.UP not in possible_moves):
			return false
		return true

	edible_grids = edible_grids.filter(filter)

	if not len(edible_grids):
	
		
		return possible_moves.pick_random()
	
	var min_dist_idx = argmin(edible_grids.map(func(g):return (abs(g.x)+abs(g.y))))
	
	var target:Vector2i = edible_grids[min_dist_idx]
	#print(target)
	var allowed_moves = [Action.STAY]
	if target.x > 0:
		allowed_moves.append(Action.RIGHT)
		
	if target.x < 0:
		allowed_moves.append(Action.LEFT)
		
	if target.y < 0:
		allowed_moves.append(Action.UP)
		
	if (target.x == target.y) and (target.x==0):


		return Action.STAY
		
	possible_moves = possible_moves.filter(func(x): return (x in allowed_moves))

	if not len(possible_moves):
		print(possible_moves_)
	

	return possible_moves.pick_random()
	

	
func argmin(array):
	if array.size() == 0:
		return -1  # Return an invalid index if the array is empty

	var min_index = 0
	var min_value = array[0]

	for i in range(1, array.size()):
		if array[i] < min_value:
			min_value = array[i]
			min_index = i
	return min_index

	
func argmax(array):
	if array.size() == 0:
		return -1  # Return an invalid index if the array is empty

	var max_index = 0
	var max_value = array[0]

	for i in range(1, array.size()):
		if array[i] > max_value:
			max_value = array[i]
			max_index = i
	return max_index



func _on_message(receiver_id, tag, message):
	if not receiver_id == id:
		return 
	var time_diff = Time.get_ticks_msec() - message.time
	
	if time_diff>100:
		print(time_diff)
	#emit_signal("action_ready", message.action)

static func use_for_snake(_snake, _env, data={}):
	var plan = PolicyNearestFoodRecorded.new()
	
	_env.add_child(plan)
	plan.use_ws_client(data.ws_client)
	plan.existing_len = len(_snake.nodes)
	_snake.use_policy(plan)

