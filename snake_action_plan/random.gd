extends Node

const UP = Types.Action.UP
const LEFT = Types.Action.LEFT
const RIGHT = Types.Action.RIGHT

var pool = [UP, UP, UP, UP, UP, RIGHT, LEFT]

func get_next_action(_snake):
	return pool[randi()%len(pool)]
	
