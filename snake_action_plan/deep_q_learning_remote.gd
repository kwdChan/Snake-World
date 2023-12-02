class_name PolicyDeepQLearning 
extends Policy

var ws_client: WSClient

var existing_len: int:
	set(v):
		existing_len = v 
@onready var id = str(get_instance_id())

var last_pos: Vector2i

#func get_subclass():
#	return PolicyDeepQLearning


func use_ws_client(_ws_client:WSClient):
	ws_client = _ws_client
	ws_client.message_received.connect(_on_message)


func step(_snake: Snake):
	if (not ws_client.open) : 
		return Action.STAY
	
	var data = _snake.get_sensory_info()
	

	
	
	data['time'] = Time.get_ticks_msec()
	
	var new_len = len(_snake.nodes) 
	data['rewards'] = (new_len - existing_len)
	#data['rewards'] +=  new_len * 0.01
	
		
	if new_len == 0:
		data['rewards'] -= 5
		
	if new_len < existing_len:
		data['rewards'] -= 0.2

	data['rewards'] = float(data['rewards'])

		
	existing_len = new_len
	ws_client.send(
		JSON.stringify(data), 
		"deep_q_pre_extracted",
		id
	)


func _on_message(receiver_id, tag, message):
	if not receiver_id == id:
		return 
	var time_diff = Time.get_ticks_msec() - message.time
	
	if time_diff>0:
		print(time_diff)
	emit_signal("action_ready", message.action)

static func use_for_snake(_snake, _env, data={}):
	var plan = PolicyDeepQLearning.new()
	
	_env.add_child(plan)
	plan.use_ws_client(data.ws_client)
	plan.existing_len = len(_snake.nodes)
	_snake.use_policy(plan)
