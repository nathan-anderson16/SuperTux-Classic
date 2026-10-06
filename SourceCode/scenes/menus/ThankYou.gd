extends Control

onready var panel = $TitleContent/Panel
onready var score_label = $TitleContent/Panel/Score
onready var player_name = $TitleContent/Panel/LineEdit
onready var http = $HTTPRequest
onready var submit_button = $TitleContent/Panel/CloseButton

const GOOGLE_SCRIPT_URL = "https://script.google.com/macros/s/AKfycbzHe0CGXAlu6GyElC6IjhUSMMD6Ns6dfHKGt8XZvZF-sEomvAglG75GQXzB1JYCbCWy/exec"

var submitting := false

func _ready():
	score_label.text = "Score: %s" % (Scoreboard.score + Scoreboard.bonus_score())
	Logger.create_summary_log()

	submitting = false
	submit_button.disabled = false

func _process(delta):
	var window_pos = OS.window_size
	var size = panel.rect_size
	panel.rect_position = Vector2((window_pos.x - size.x) / 2, (window_pos.y - size.y) / 2)

func get_datetime_string() -> String:
	var now = OS.get_datetime()
	return "%04d-%02d-%02d %02d:%02d:%02d" % [
		now.year, now.month, now.day, now.hour, now.minute, now.second
	]

func _on_CloseButton_pressed():
	if submitting:
		return

	submitting = true
	submit_button.disabled = true

	var name = player_name.text.strip_edges()
	var score = Scoreboard.score + Scoreboard.bonus_score()
	var datetime = get_datetime_string()
	var player_id = Scoreboard.player_id

	var data = {
		"datetime": datetime,
		"name": name,
		"score": score,
		"player_id": player_id
	}

	# IMPORTANT FOR HTML5/itch:
	# Using application/json triggers CORS preflight (OPTIONS) in browsers.
	# text/plain is a "simple request" and usually avoids being blocked.
	var headers = ["Content-Type: text/plain; charset=utf-8"]
	var body = to_json(data)

	print("Submitting payload: ", body)

	var err = http.request(GOOGLE_SCRIPT_URL, headers, true, HTTPClient.METHOD_POST, body)
	print("HTTPRequest.request() err: ", err)

	# Do NOT change screens here; wait for request_completed.

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	print("HTTP completed. result=", result, " response_code=", response_code)
	print("Body: ", body.get_string_from_utf8())

	if response_code == 200:
		print("Submitted successfully!")
		Global.goto_title_screen()
	else:
		print("Failed submit. code=", response_code)
		submitting = false
		submit_button.disabled = false

func _on_Button_pressed():
	Global.goto_title_screen()
