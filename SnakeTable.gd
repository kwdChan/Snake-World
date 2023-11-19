extends Tree

@onready var _env := get_node('../Env')
@onready var root: TreeItem = create_item()



var row_bySnakeId = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	hide_root = true
	set_select_mode(1)
	
	set_column_title(0, ' Snake Name ')
	set_column_title(1, ' Length ')
	set_column_title(2, ' Colour / Hue Value ')
	set_column_expand(0, false)
	set_column_expand(1, false)
	
	set_column_expand(2, true)
	set_column_title_alignment(0, HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER)
	set_column_title_alignment(1, HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER)
	set_column_title_alignment(2, HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER)
	
	
	_env.snake_list_change.connect(update_tree)
	update_tree()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	update_tree()
	
func update_tree():
	

	var all_snake_name = []
	for snake_ in _env.get_all_snakes():

		update_row(snake_)
		all_snake_name.append(snake_.get_instance_id())
		
	for snake_id in row_bySnakeId:
		if not snake_id in all_snake_name:

			row_bySnakeId[snake_id].free()
			row_bySnakeId.erase(snake_id) 
			

func update_row(snake: Snake):
	if not snake.get_instance_id() in row_bySnakeId:
		var new_row : TreeItem = create_item(root)
		row_bySnakeId[snake.get_instance_id()] = new_row
		#new_row.set_text_alignment(0, HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER)
		new_row.set_text_alignment(1, HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER)
		new_row.set_text_alignment(2, HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER)
		new_row.set_metadata(0, snake.get_instance_id())
		

	var row: TreeItem = row_bySnakeId[snake.get_instance_id()]

	row.set_text(0, "%s" % snake.name)
	row.set_text(1, "%s" % len(snake.nodes))
	row.set_text(2, "%.2f" % snake.colour.h)
	
	var icon = CanvasTexture.new()
	
	print(icon.get_size())
	
	#icon.set_texture_repeat(TextureRepeat.TEXTURE_REPEAT_MAX)
	row.set_icon(2, icon)
	row.set_icon_modulate(2, Color.from_hsv(snake.colour.h, 1, 1))
	row.set_icon_region(2, Rect2(0, 0, 10, 10))
	

func get_snake_from_item(tree_item: TreeItem) -> Snake:
	var matches = _env.get_all_snakes().filter(func(s): return (s.get_instance_id()==tree_item.get_metadata(0)))
	if len(matches): 
		return matches[0]
	else:
		return null
	
	
