class_name PolicyUserInput
extends Policy

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



func step(_snake):
	var _next_action = next_action
	next_action = Action.STAY
	to_turn = false
	
	emit_signal('action_ready', _next_action)
	return 
	

static func use_for_snake(_snake, _env, data={}):
	var plan = PolicyUserInput.new()
	_env.add_child(plan)
	_snake.use_policy(plan)
	
	
