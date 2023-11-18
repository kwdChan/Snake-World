extends Control


func _ready():
	pass # Replace with function body.


func _process(_delta):
	var grids = $Env.get_all_grids()
	var origin = $Env.all_snakes[0].node_positions[0]
	var direction = $Env.all_snakes[0].direction
	if not origin:
		return

	
	var rotation = Vector2(direction).angle_to(Vector2.UP)
	for i in range(len(grids)):
		
		grids[i] = (Vector2(grids[i] - origin)).rotated(rotation)
		grids[i] = Vector2i(round(grids[i]))

	$Vision.draw_grids(grids)
	pass
