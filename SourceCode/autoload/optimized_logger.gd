extends Node

var event_log: Array = []

var jumps = 0
var deaths = 0
# ... What else?

 
onready var http_request = $HTTPRequest

func _ready():
	set_process(true)
	set_process_input(true)

func add_to_event_log(event, state, timer, score, zone) :
	event_log.append([event, state, timer, score, zone])

func send_event_log() :
	var compressed = ""
	
	var last_item = null
	for item in event_log :
		for i in range(len(item)) :
			if last_item == null or item[i] != last_item[i] :
				compressed += item[i] 
	
	var form_url = "https://docs.google.com/forms/d/e/1FAIpQLSegtXvnfveEen1Zb_PDYziZ44WCGZBiYq3b2JIeWVqOInwzCA/formResponse?entry.1934454714=" + compressed
	var headers = ["Content-Type: application/x-www-form-urlencoded", "Content-Length: " + str(len(compressed))]

	var result = http_request.request(form_url, headers, true, HTTPClient.METHOD_POST, "")
	
	send_summary_log()
	
	event_log.clear()
	
func send_summary_log() :
	var data = ""
	
	data += event_log[-1][2]
	data += event_log[-1][3]
	data += str(jumps)
	data += str(deaths)
	
	data += "REPLACE WITH QoE DATA!!!"
	
	# TODO: Fix for url for summary URL
	var form_url = "https://docs.google.com/forms/d/e/1FAIpQLSegtXvnfveEen1Zb_PDYziZ44WCGZBiYq3b2JIeWVqOInwzCA/formResponse?entry.1934454714=" + data
	var headers = ["Content-Type: application/x-www-form-urlencoded", "Content-Length: " + str(len(data))]

	var result = http_request.request(form_url, headers, true, HTTPClient.METHOD_POST, "")
	
