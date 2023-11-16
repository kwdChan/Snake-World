extends Node

var pool = ['up', 'up', 'up', 'up', 'up', 'left', 'right']
func get_next_action(snake):
	return pool[randi()%len(pool)]
	
