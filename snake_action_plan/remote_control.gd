class_name PolicyRemoteControl
extends Policy

var ws_client: WSClient



@onready var id = str(get_instance_id())

func use_ws_client(_ws_client:WSClient):
	ws_client = _ws_client
	ws_client.message_received.connect(_on_message)
	

func step(_snake: Snake):
	if (not ws_client.open) : 
		return Action.STAY
	
	var data = _snake.get_sensory_info()
	data['time'] = Time.get_ticks_msec()
	
	ws_client.send(
		JSON.stringify(data), 
		"PolicyRemoteControl",
		id
	)



func _on_message(receiver_id, tag, message):
	if not receiver_id == id:
		return 

	print(Time.get_ticks_msec() - message.time)
	emit_signal("action_ready", message.action)
	

static func use_for_snake(_snake, _ws_client, _env):
	var plan = PolicyRemoteControl.new()
	
	_env.add_child(plan)
	plan.use_ws_client(_ws_client)
	_snake.use_policy(plan)
	
	
	
	
	
