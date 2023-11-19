class_name ActionPlan
extends Node

const Action := Types.Action

func get_next_action(_snake: Types.Snake) -> Action:
	return Action.STAY
	
