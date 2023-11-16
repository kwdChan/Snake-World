extends Node

var next_action = ''


func _process(delta):
	
	if Input.is_action_just_pressed('ui_right'):
		next_action = 'right'
		
	if Input.is_action_just_pressed('ui_left'):
		next_action = 'left'
		
	if Input.is_action_just_pressed('ui_up'):
		next_action = 'up'


func get_next_action(snake):
	var _next_action = next_action
	next_action = ''
	return _next_action
	
