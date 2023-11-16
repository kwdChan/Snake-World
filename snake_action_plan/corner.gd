extends Node


var next_idx = 0

func get_next_action(snake):
	next_idx += 1
	
	return ['up', 'left', 'right'][next_idx%3]
	
