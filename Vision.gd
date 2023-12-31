extends Node2D
var _vision_offset_pix = Vector2(0, 0)
var _vision_grid_pix = 5
var _grids_to_draw = []

var origin: Vector2i
var direction: Vector2i

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _draw():

	for grid_ in _grids_to_draw:
		_draw_grid(grid_)
	_draw_grid(Vector2i(0,0), Color(255,0,0))
	
func draw_grids(grids):
	_grids_to_draw = grids


func _draw_grid(grid, color=Color(1,1,1,1)):
	
	var pix = grid2pix(grid)
	draw_rect(
		Rect2(pix.x, pix.y, _vision_grid_pix,_vision_grid_pix ),
		color
	)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	queue_redraw()
	
	
func grid2pix(grid):
	# TODO
	return _vision_offset_pix + Vector2((Vector2i(1,1)+grid) * _vision_grid_pix)
