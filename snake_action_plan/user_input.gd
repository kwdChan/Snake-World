extends ActionPlan

var next_action := Action.STAY
var to_turn: bool = false

func _process(_delta):
	if Input.is_action_pressed('ui_up'):
		
		if not to_turn:
			next_action =  Action.UP
		
	if Input.is_action_just_pressed('ui_right'):
		next_action =  Action.RIGHT
		to_turn = true
		
	if Input.is_action_just_pressed('ui_left'):
		next_action =  Action.LEFT
		to_turn = true



func get_next_action(_snake):
	var _next_action = next_action
	next_action = Action.STAY
	to_turn = false
	return _next_action
	
