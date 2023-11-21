class_name Policy
extends Node

signal action_ready(actioncode: Types.Action)
const Action := Types.Action
 
func step(_snake: Snake) -> void:
	action_ready.emit(Action.STAY)
	

