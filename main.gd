extends Control


func _ready():
	pass # Replace with function body.


func _process(_delta):
	var grids = $Env.get_all_grids()

	$Vision.draw_grids($Env.all_snakes[0].to_perspective(grids))

