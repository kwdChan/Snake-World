class_name WSClient
extends Node

signal socket_closed
signal message_received(receiver_id, tag, message)

var received_messsages: Array[Dictionary] = [] 
var socket = WebSocketPeer.new()
var state 
var open := false

func _ready():
	socket.connect_to_url("ws://localhost:8001")


func _process(delta):
	socket.poll()
	
	state = socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		open = true
		while socket.get_available_packet_count():
			var data = JSON.parse_string(socket.get_packet().get_string_from_utf8())
			message_received.emit(data.receiver_id, data.tag, data.message, )

	elif state == WebSocketPeer.STATE_CLOSING:
		open=false
		pass
		
	elif state == WebSocketPeer.STATE_CLOSED:
		open = false
		socket_closed.emit()
		set_process(false)

func send(message, tag, receiver_id):

	assert (state == WebSocketPeer.STATE_OPEN)
	socket.send_text(JSON.stringify({tag=tag, message=message, receiver_id=receiver_id}))
	


