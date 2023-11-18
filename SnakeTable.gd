extends Tree

@onready var _env := get_node('../Env')
@onready var root: TreeItem = create_item()



var row_bySnakeId = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	hide_root = true

	set_column_title(0, ' Snake Name ')
	set_column_title(1, ' Length ')
	set_column_expand(0, false)
	set_column_expand(1, false)
	
	
	set_column_title_alignment(0, HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER)
	set_column_title_alignment(1, HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER)

	
	
	_env.snake_list_change.connect(update_tree)
	update_tree()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_tree()

func update_tree():
	
	var c = 0
	var all_snake_name = []
	for snake_ in _env.get_all_snakes():
		c += 1
		update_row(snake_)
		all_snake_name.append(snake_.get_instance_id())
		
	for snake_id in row_bySnakeId:
		if not snake_id in all_snake_name:

			row_bySnakeId[snake_id].free()
			row_bySnakeId.erase(snake_id) 
			

func update_row(snake):
	if not snake.get_instance_id() in row_bySnakeId:
		row_bySnakeId[snake.get_instance_id()] = create_item(root)
		#row_bySnakeId[snake.get_instance_id()].set_text_alignment(0, HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER)
		row_bySnakeId[snake.get_instance_id()].set_text_alignment(1, HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER)
	var row: TreeItem = row_bySnakeId[snake.get_instance_id()]
	
	row.set_text(0, "%s" % snake.name)
	row.set_text(1, "%s" % len(snake.nodes))
	
	
	

	
		
	
	
