extends Node

var state_type_map = {
	"idle": "a",
	"duck": "b",
	"walk": "c",
	"jump": "d",
	"fall": "e",
	"dead": "f",
	"win": "g",
}

var event_type_map = {
	"DELAY_ENTER": "A",
	"DELAY_EXIT": "B",
	"CHECKPOINT": "C",
	"FINISH": "D",
	"DEATH": "E",
	"LEFT": "F",
	"RIGHT": "G",
	"JUMP": "H",
}

var event_log: Array = []

onready var http_request_e = $"/root/Scoreboard/HTTPRequestE"
onready var http_request_s = $"/root/Scoreboard/HTTPRequestS"

func _ready():
	set_process(true)
	set_process_input(true)

# Timer (6 digit) will be in every update, so it goes first
# Event will be capital letters A-Z
# State will be lowercase letters a-z
# Score will be 4 digits
# Zone will be 2 digits
func add_to_event_log(e) :

	var event = event_type_map[e]
	
	var timer = str($"/root/Scoreboard".timer_text.text).substr(7)
	
	while len(timer) < 6 :
		timer = "0" + timer

	var state = state_type_map[Global.player.state_machine.state]
	var score = str($"/root/Scoreboard".coins_text.text)
	
	while len(score) < 4 :
		score = "0" + score
	
	if len(score) > 4 :
		score = "????"
		
	var zone = str(Global.current_zone)
	
	while len(zone) < 2 :
		zone = "0" + zone
	
	event_log.append([timer, event, state, score, zone])

func send_event_log() :
	# TODO lag amount and player ID
	var compressed = ""
	
	compressed += Scoreboard.player_id + "_"
	
	var last_item = null
	for item in event_log :
		compressed += item[0]
		for i in range(1, len(item)) :
			if last_item == null or item[i] != last_item[i] :
				compressed += item[i] 
	
	var form_url = "https://docs.google.com/forms/d/e/1FAIpQLSegtXvnfveEen1Zb_PDYziZ44WCGZBiYq3b2JIeWVqOInwzCA/formResponse?entry.1934454714=" + compressed
	var headers = ["Content-Type: application/x-www-form-urlencoded", "Content-Length: 0"]
	
	print(form_url)
	
	var result = http_request_e.request(form_url, headers, true, HTTPClient.METHOD_POST, "")
	print("Result: ", result)
	event_log.clear()
	
func send_summary_log(QOE_Result) :
	var timer = str($"/root/Scoreboard".timer_text.text).substr(7)
	var coins = str($"/root/Scoreboard".coins_text.text)
	var deaths = str($"/root/Scoreboard".number_of_deaths)
	
	var data = ""
	
	data += Scoreboard.player_id + "_"
	
	data += str(timer)
	data += "_"
	data += str(coins)
	data += "_"
	data += str(deaths)
	data += "_"
	data += QOE_Result
	
	# TODO: Fix for url for summary URL
	var form_url = "https://docs.google.com/forms/d/e/1FAIpQLSelQVDbEVX93LgRN-XQxCdKg68diD8ovHqOw4IcKrHCYQzLxQ/formResponse?entry.1934454714=" + data
	var headers = ["Content-Type: application/x-www-form-urlencoded", "Content-Length: 0"]
	
	print(form_url)
	var result = http_request_s.request(form_url, headers, true, HTTPClient.METHOD_POST, "")
	print("SResult: ", result)
