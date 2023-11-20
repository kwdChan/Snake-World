@tool
extends Polygon2D



# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Engine.is_editor_hint():
		var WORLD_PARAMS = get_node("..").WORLD_PARAMS

		polygon = PackedVector2Array([
			Vector2(0, 0), 
			Vector2((WORLD_PARAMS.SIZE_GRID.x+1)*WORLD_PARAMS.GRID_SIZE_PIX, 0), 
			(WORLD_PARAMS.SIZE_GRID + Vector2.ONE) * WORLD_PARAMS.GRID_SIZE_PIX, 
			Vector2(0, (WORLD_PARAMS.SIZE_GRID.y+1)*WORLD_PARAMS.GRID_SIZE_PIX), 
		])
		queue_redraw()
