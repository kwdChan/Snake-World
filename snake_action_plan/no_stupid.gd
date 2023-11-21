class_name NoStupidMove
extends Policy
const UP = Action.UP
const LEFT = Action.LEFT
const RIGHT = Action.RIGHT
const STAY = Action.STAY
var distance: float = 3

var pool := [UP, UP, UP, UP, UP, LEFT, RIGHT]



func get_non_stupid_moves(_snake):
	var body_grids = _snake.to_perspective(_snake.get_body_grids())
	var dead_grids = _snake.to_perspective(_snake._env.get_inedible_grids())
	var nogo_grids = _snake.to_perspective(_snake._env.world_boundry_grids)

	
	var possible_moves = _get_non_stupid_moves(nogo_grids, 1.3, _snake)
	
	var non_stupid_moves = _get_non_stupid_moves(body_grids+dead_grids, distance, _snake, possible_moves)
	
	if not len(non_stupid_moves):
		non_stupid_moves = _get_non_stupid_moves(dead_grids, distance, _snake, possible_moves)
	if not len(non_stupid_moves):
		non_stupid_moves = [Action.STAY]
	
	return non_stupid_moves
	

	
func _get_non_stupid_moves(avoid_grids, _distance:float, _snake, _pool=pool):
	
	var possible_moves = _pool.duplicate()

	for grid_ in avoid_grids:
		if grid_.length() > _distance: 
		
			continue
		#print(grid_.length())
		if (grid_.x <= _distance) and (grid_.x > 0) :
			possible_moves.erase(Action.RIGHT)
			
		if (grid_.x >= -_distance) and (grid_.x < 0) :
			possible_moves.erase(Action.LEFT)
			
		if (grid_.y >= -_distance) and (grid_.y < 0):
			possible_moves = possible_moves.filter(func (x): return (x!=Action.UP))
	
	if len(possible_moves):
		return possible_moves
		
	elif not len(possible_moves) and (_distance>1):
		return _get_non_stupid_moves(avoid_grids, _distance-1, _snake, _pool)
	else:
		return []
		
	
