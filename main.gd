extends Control

@onready var selected_snake: Snake = $Env.all_snakes[0]
var show_edible = true
var vision_rotate = false
func _ready():
	pass

func get_valid_selected_snake():
	if not is_instance_valid(selected_snake):
		if len($Env.all_snakes):
			return $Env.all_snakes[0]
		else:
			return null
	return selected_snake
	
func _process(_delta):
	var grids = $Env.get_inedible_grids()
	var the_snake = get_valid_selected_snake()
	if the_snake == null:
		return 
		
	var grids_to_show = the_snake.to_perspective(
		$Env.get_inedible_grids()+$Env.world_boundry_grids,
		vision_rotate)
	
	if show_edible:
		grids_to_show.append_array(
			the_snake.to_perspective($Env.get_edible_grids(), vision_rotate)
		)
		
	$Vision.draw_grids(grids_to_show)

	



func _on_snake_table_item_selected():
	selected_snake =  ($SnakeTable.get_snake_from_item($SnakeTable.get_selected()))

func _on_vision_show_food_toggled(button_pressed):
	show_edible = not button_pressed 

func _on_vision_rotate_toggled(button_pressed):
	vision_rotate = button_pressed

