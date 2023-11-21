class_name PolicyNearestFood
extends NoStupidMove

var food_distance = 200


func step(_snake) :

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
	
		emit_signal("action_ready", possible_moves.pick_random())
		return 
	
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

		emit_signal("action_ready", Action.STAY)
		return 
		
	possible_moves = possible_moves.filter(func(x): return (x in allowed_moves))
	#print(possible_moves)
	if not len(possible_moves):
		print(possible_moves_)
		

	emit_signal("action_ready", possible_moves.pick_random())
	return
	
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


static func use_for_snake(snake, env):
	var plan = PolicyNearestFood.new()
	
	env.add_child(plan)
	snake.use_policy(plan)
	
