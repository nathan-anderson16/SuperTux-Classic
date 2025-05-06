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
	"LEFT_RELEASE": "I",
	"RIGHT_RELEASE": "J",
	"JUMP_RELEASE": "K",
}

var jumps = 0
var lefts = 0
var rights = 0

var current_checkpoint = 0

var event_log: Array = []

var time_in_zone = {}
var times_entered_zone = {}
var times_died_in_zone = {}
var score_in_zone = {}

onready var http_request_e = $"/root/Scoreboard/HTTPRequestE"
onready var http_request_s = $"/root/Scoreboard/HTTPRequestS"

func _ready():
	set_process(true)
	set_process_input(true)

var last_score = 0
func _process(delta) :
	if Global.current_zone in time_in_zone.keys() :
		time_in_zone[Global.current_zone] += delta
	else :
		time_in_zone[Global.current_zone] = 0
	
	var score_delta = int(str($"/root/Scoreboard".coins_text.text)) - last_score
	if score_delta > 0 :
		if Global.current_zone in score_in_zone.keys() :
			score_in_zone[Global.current_zone] += score_delta
		else :
			score_in_zone[Global.current_zone] = score_delta
	
	last_score = int(str($"/root/Scoreboard".coins_text.text))

func format_timer() :
	var timer = ""
	var t = Scoreboard.level_timer.time_left
	if t < 0 :
		timer += "-"
	else :
		timer += "+"
	
	t = str(abs(t))
	var t1 = t.substr(0, t.find("."))
	while len(t1) < 3 :
		t1 = "0" + t1
	
	var t2 = t.substr(t.find(".") + 1, 3)
	while len(t2) < 3 :
		t2 = t2 + "0"
		
	timer += t1 + t2
	
	return timer
# Timer (6 digit) will be in every update, so it goes first
# Event will be capital letters A-Z
# State will be lowercase letters a-z
# Score will be 4 digits
# Zone will be 2 digits
func add_to_event_log(e) :
	
	if e == "DEATH" :
		score_in_zone.clear()
	if e == "JUMP" :
		jumps += 1
	if e == "LEFT" :
		lefts += 1
	if e == "RIGHT" :
		rights += 1
	
	var event = event_type_map[e]
	
	var timer = format_timer()
	
#	print(timer)

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
		var temp = ""
		for i in range(1, len(item)) :
			if last_item == null or item[i] != last_item[i] :
				temp += item[i]
		if temp != "" :
			compressed += item[0] + temp
		last_item = item
	
	var form_url = "https://docs.google.com/forms/d/e/1FAIpQLSegtXvnfveEen1Zb_PDYziZ44WCGZBiYq3b2JIeWVqOInwzCA/formResponse?entry.1934454714=" + compressed
	var headers = ["Content-Type: application/x-www-form-urlencoded", "Content-Length: 0"]
	
	print(form_url)
	
	var result = http_request_e.request(form_url, headers, true, HTTPClient.METHOD_POST, "")
	print("Result: ", result)
	event_log.clear()

func send_summary_log(QOE_Result) :
	
	var time_since_last_checkpoint = Scoreboard.last_checkpoint_time - Scoreboard.level_timer.time_left
	
	var coins = str($"/root/Scoreboard".coins_text.text)
	var deaths = str($"/root/Scoreboard".number_of_deaths)
	
	var data = ""
	var lag = Global.next_level_lag
	
	data += Scoreboard.player_id + "_"
	
	data += format_timer()
	data += "_"
	data += str(lag)
	data += "_"
	data += str(score_in_zone).replace(" ", "")
	data += "_"
	data += str($"/root/Scoreboard".timer_text.text).substr(7)
	data += "_"
	data += str(jumps)
	data += "_"
	data += str(lefts)
	data += "_"
	data += str(rights)
	data += "_"
	data += str(times_died_in_zone).replace(" ", "")
	data += "_"
	data += str(time_since_last_checkpoint)
	data += "_"
	data += str(current_checkpoint)
	data += "_"
	data += QOE_Result
	data += "_"
	data += str(time_in_zone).replace(" ", "")
	data += "_"
	data += str(times_entered_zone).replace(" ", "")
	
	# TODO: Fix for url for summary URL
	var form_url = "https://docs.google.com/forms/d/e/1FAIpQLSelQVDbEVX93LgRN-XQxCdKg68diD8ovHqOw4IcKrHCYQzLxQ/formResponse?entry.1934454714=" + data
	var headers = ["Content-Type: application/x-www-form-urlencoded", "Content-Length: 0"]
	
	print(form_url)
	var result = http_request_s.request(form_url, headers, true, HTTPClient.METHOD_POST, "")
	print("SResult: ", result)
	
	print(time_in_zone)
