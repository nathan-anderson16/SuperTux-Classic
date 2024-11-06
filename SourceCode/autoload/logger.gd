extends Node

var frame_log_path: String = "" 
var event_log_path: String = "" 
var tux_file: Node = null
var previous_state = ""
var init = false

func _ready():
	
	set_process(true)
	var datetime = OS.get_datetime()
	var log_title_timestamp = str(datetime.year) + "-" + str(datetime.month).pad_zeros(2) + "-" + str(datetime.day).pad_zeros(2) + "_" + str(datetime.hour).pad_zeros(2) + "-" + str(datetime.minute).pad_zeros(2) + "-" + str(datetime.second).pad_zeros(2)
	frame_log_path = OS.get_user_data_dir() + "/logs/frame_log_" + log_title_timestamp + ".csv"
	event_log_path = OS.get_user_data_dir() + "/logs/event_log_" + log_title_timestamp + ".csv"
	
	var dir = Directory.new()
	if !dir.dir_exists(OS.get_user_data_dir() + "/logs"):
		var make_dir_result = dir.make_dir(OS.get_user_data_dir() + "/logs")
		if make_dir_result != OK:
			print("Failed to create logs directory!")
	
	initialize_logs()
	init = true
	
func initialize_logs():
	create_log(frame_log_path, "Timestamp,Level,State,Timer,Coins,Lives,Deaths,X-Position,Y-Position,X-Velocity,Y-Velocity,FPS,TickRate")
	create_log(event_log_path, "Timestamp,Level,State,Timer,Coins,Lives,Deaths")
	
func create_log(path: String, header: String):
	var file = File.new()
	if file.open(path, File.WRITE) == OK:
		file.store_line(header)
	file.close()
	
func log_frame():
	if !init:
		return
		
	var datetime = OS.get_datetime()
	var micro = str(Time.get_unix_time_from_system()).split(".")[1]
	var timestamp =  str(datetime.hour).pad_zeros(2) + ":" + str(datetime.minute).pad_zeros(2) + ":" + str(datetime.second).pad_zeros(2) + "." + micro
	var current_level_path = $"/root/Global".current_level_path
	var level_parts = current_level_path.split("/")
	var level_result = (level_parts[-1]).split(".")[0]
	var state = Global.player.state_machine.state
	var timer = str($"/root/Scoreboard".timer_text.text)
	var coins = str($"/root/Scoreboard".coins_text.text)
	var lives = str($"/root/Scoreboard".lives_text.text)
	var deaths = str($"/root/Scoreboard".number_of_deaths)
	var x_position = str(Global.player.get_position()).split("(")[1].split(",")[0]
	var y_position = str(Global.player.get_position()).split(",")[1].split(")")[0].split(" ")[1]
	var x_velocity = str(Global.player.velocity).split("(")[1].split(",")[0]
	var y_velocity = str(Global.player.velocity).split(",")[1].split(")")[0].split(" ")[1]
	var fps = str(Engine.get_frames_per_second())
	var tick_rate = str(Engine.iterations_per_second)
	
	var frame_message = timestamp + "," + level_result + "," + state + "," + timer + "," + coins + "," + lives + "," + deaths + "," + x_position + "," + y_position + "," + x_velocity + "," + y_velocity + "," + fps + "," + tick_rate
	write_to_file(frame_log_path, frame_message)
	
func log_event():
	if !init:
		return
		
	var datetime = OS.get_datetime()
	var micro = str(Time.get_unix_time_from_system()).split(".")[1]
	var timestamp =  str(datetime.hour).pad_zeros(2) + ":" + str(datetime.minute).pad_zeros(2) + ":" + str(datetime.second).pad_zeros(2) + "." + micro
	var current_level_path = $"/root/Global".current_level_path
	var level_parts = current_level_path.split("/")
	var level_result = (level_parts[-1]).split(".")[0]
	var state = Global.player.state_machine.state
	var timer = str($"/root/Scoreboard".timer_text.text)
	var coins = str($"/root/Scoreboard".coins_text.text)
	var lives = str($"/root/Scoreboard".lives_text.text)
	var deaths = str($"/root/Scoreboard".number_of_deaths)
	
	var event_message = timestamp + "," + level_result + "," + state + "," + timer + "," + coins + "," + lives + "," + deaths
	write_to_file(event_log_path, event_message)
	
func write_to_file(path: String, message: String):
		var file = File.new()
		if file.open(path, File.READ_WRITE) == OK:
			file.seek_end()
			file.store_line(message)
		file.close()
	
func _process(delta):
	if is_instance_valid(Global.player):
		var state_machine = Global.player.get_node("state_machine")
		if state_machine != null:
			var current_state = state_machine.state
			log_frame()
			if current_state != previous_state:
				log_event()
				previous_state = current_state
