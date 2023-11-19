extends Control


func _ready():
	pass


func _process(_delta):
	var grids = $Env.get_inedible_grids()
	if not len($Env.all_snakes):
		return
	$Vision.draw_grids($Env.all_snakes[0].to_perspective(grids))
	#print($SnakeTable.get_selected ( ) )
	
