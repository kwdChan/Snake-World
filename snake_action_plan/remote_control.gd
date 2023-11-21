class_name RemoteControl
extends ActionPlan

var ws_client: WSClient

var responses: Array[Dictionary] = []

@onready var id = str(get_instance_id())

func use_ws_client(_ws_client:WSClient):
	ws_client = _ws_client
	ws_client.message_received.connect(_on_message)
	

func get_next_action(_snake: Snake):
	if (not ws_client.open) : 
		return Action.STAY
	
	var data = _snake.get_sensory_info()
	data['time'] = Time.get_ticks_msec()
	
	ws_client.send(
		JSON.stringify(data), 
		"RemoteControl",
		id
	)
	var res = responses.pop_front()
	if res:
		var t = Time.get_ticks_msec()
		
		print(t - res.time)
		return res.action
	else:
		return Action.STAY


func _on_message(receiver_id, tag, message):
	

	if not receiver_id == id:
		return 

	responses.append({time = message.time, action = message.action})
	
	

static func use_for_snake(_snake, _ws_client, _env):
	var plan = RemoteControl.new()
	
	_env.add_child(plan)
	plan.use_ws_client(_ws_client)
	_snake.use_action_plan_obj(plan)
	
	
	
	
	
