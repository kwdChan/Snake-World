extends ActionPlan
const UP := Action.UP
const RIGHT := Action.RIGHT
const LEFT := Action.LEFT

var pool = [UP, UP, UP, UP, UP, RIGHT, LEFT]

func get_next_action(_snake):
	return pool.pick_random()
	
