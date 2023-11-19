extends Control


func _ready():
	pass


func _process(_delta):
	var grids = $Env.get_inedible_grids()

	$Vision.draw_grids($Env.all_snakes[0].to_perspective($Env.get_inedible_grids()+$Env.world_boundry_grids))

	
	#print($SnakeTable.get_selected ( ) )
	
