class_name PolicyDeepQLearning 
extends Policy

var ws_client: WSClient

var existing_pos: Vector2i
var existing_len: int
		
@onready var id = str(get_instance_id())

var last_pos: Vector2i

#func get_subclass():
#	return PolicyDeepQLearning


func use_ws_client(_ws_client:WSClient):
	ws_client = _ws_client
	ws_client.message_received.connect(_on_message)


func step(_snake: Snake):
	if (not ws_client.open) : 
		emit_signal("action_ready", Action.STAY)
		return 

	
	var data = _snake.get_sensory_info()
	data['time'] = Time.get_ticks_msec()
	# rewards
	var new_len = len(_snake.nodes) 
	var new_pos
	if new_len:
		new_pos = _snake.nodes[0].grid_pos
	else: 
		new_pos = Vector2i(0,0)
	
	# there's one step delay before the snake knows it has eaten. so we have to detect it ourselves
	data['rewards'] = 0
	
	if _snake.if_just_ate():
		data['rewards'] += 1 
		
	# punishment
	data['rewards'] += min(new_len-existing_len, 0) 
	
	if _snake.if_got_attacked():
		data['rewards']  -= 0.01 # marker
	
	if new_len == 0:
		data['rewards'] -= 5.005 # marker
		
	existing_pos = new_pos
	existing_len = new_len
	
	ws_client.send(
		JSON.stringify(data), 
		"infer",
		id
	)


func _on_message(receiver_id, tag, message):
	if not receiver_id == id:
		return 
	var time_diff = Time.get_ticks_msec() - message.time
	
	if time_diff>100:
		print(time_diff)
	emit_signal("action_ready", message.action)

static func use_for_snake(_snake, _env, data={}):
	var plan = PolicyDeepQLearning.new()
	
	_env.add_child(plan)
	plan.use_ws_client(data.ws_client)
	plan.existing_len = len(_snake.nodes)
	_snake.use_policy(plan)
