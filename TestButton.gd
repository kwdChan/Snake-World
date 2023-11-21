extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _process(delta):
	pass


func _on_pressed():
	print('pressed')
	var ws_client = WSClient.new()
	add_child(ws_client)
	#print(ws_client)
