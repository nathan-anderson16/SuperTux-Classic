extends Node

var frame_log_path: String = "" 
var frame_logs: Array = [] 
var event_log_path: String = "" 
var event_logs: Array = []
var qoe_log_path: String = "" 
var qoe_logs: Array = []
var player_id_path: String = "" 
var round_data_path: String = ""
var level_data = {}
var summary_log_path: String = "" 
var current_round = 1
var frame_logs_by_round = {}
var event_logs_by_round = {}
var qoe_logs_by_round = {}
var round_summaries = []
var frame_summary: Array = []
var event_summary: Array = []
var qoe_summary: Array = []
var previous_state = ""
var init = false
var last_frame_time: float = 0.0
var frame_time: float = 0.0
var cumulative_time: float = 0.0
var frame_count: int = 0
var start_time: int = OS.get_ticks_msec() 
var tick_rate: float = 0.0 
const TICK_RATE_INTERVAL: float = 1.0
var current_frame_time: float = 0.0

func _ready():
	
	set_process(true)
	set_process_input(true)
	
	var datetime = OS.get_datetime()
	var log_title_timestamp = str(datetime.year) + "-" + str(datetime.month).pad_zeros(2) + "-" + str(datetime.day).pad_zeros(2) + "_" + str(datetime.hour).pad_zeros(2) + "-" + str(datetime.minute).pad_zeros(2) + "-" + str(datetime.second).pad_zeros(2)
	last_frame_time = OS.get_ticks_usec() / 1000.0
	var logs_base_dir = OS.get_user_data_dir() + "/logs"
	var frame_logs_dir = logs_base_dir + "/frame_logs"
	var event_logs_dir = logs_base_dir + "/event_logs"
	var qoe_logs_dir = logs_base_dir + "/qoe_logs"
	var summary_logs_dir = logs_base_dir + "/summary_logs"
	
	frame_log_path = frame_logs_dir + "/frame_log_" + log_title_timestamp + ".csv"
	event_log_path = event_logs_dir + "/event_log_" + log_title_timestamp + ".csv"
	qoe_log_path = qoe_logs_dir + "/qoe_log_" + log_title_timestamp + ".csv"
	summary_log_path = summary_logs_dir + "/summary_log_" + log_title_timestamp + ".csv"
	player_id_path = "res://harness/player_id.txt"
	round_data_path = "res://harness/round_data.txt"
	load_level_data(round_data_path)
	
	var dir = Directory.new()
	if !dir.dir_exists(logs_base_dir):
		dir.make_dir(logs_base_dir)
	if !dir.dir_exists(frame_logs_dir):
		dir.make_dir(frame_logs_dir)
	if !dir.dir_exists(event_logs_dir):
		dir.make_dir(event_logs_dir)
	if !dir.dir_exists(qoe_logs_dir):
		dir.make_dir(qoe_logs_dir)
	if !dir.dir_exists(summary_logs_dir):
		dir.make_dir(summary_logs_dir)
	
	initialize_logs()
	init = true
	
func _process(delta):
	cumulative_time += delta 
	frame_count += 1
	
	var current_time = OS.get_ticks_msec()
	var elapsed_time = (current_time - start_time) / 1000.0 

	if elapsed_time >= TICK_RATE_INTERVAL:
		tick_rate = frame_count / elapsed_time
		print("Tick Rate:", tick_rate)

		start_time = current_time
		frame_count = 0
		
	if Input.is_action_just_released("jump"):
		Logger.log_event("Pressed Jump")
		
	if Input.is_action_just_pressed("move_right"):
		Logger.log_event("Pressed Right")
		
	if Input.is_action_just_pressed("move_left"):
		Logger.log_event("Pressed Left")
	
	if is_instance_valid(Global.player) and Global.player.has_node("state_machine"):
		var state_machine = Global.player.get_node("state_machine") if Global.player.has_node("state_machine") else null
		if state_machine != null:
			var current_state = state_machine.state
			log_frame(delta, cumulative_time)
			if current_state != previous_state:
				log_event()
				previous_state = current_state
	
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		write_to_disk() 
		create_round_summary(current_round)
		create_summary_log() 
		print("Game is closing. Summary log created.")
		get_tree().quit() 

func start_new_round():
	write_to_disk() 
	create_round_summary(current_round)
	current_round += 1
	frame_logs.clear()
	event_logs.clear()
	qoe_logs.clear()

func read_int_from_file(file_path: String) -> int:
	var file = File.new()
	if file.open(file_path, File.READ) == OK:
		var content = file.get_line().strip_edges()
		file.close()
		return int(content)
	else:
		print("Failed to open file: ", file_path)
		return 0
		
func load_level_data(file_path: String):
	var file = File.new()
	if file.open(file_path, File.READ) == OK:
		file.get_line()
		while not file.eof_reached():
			var line = file.get_line().strip_edges()
			if line != "":
				var parts = line.split(",")
				if parts.size() == 3:
					var path = parts[0]
					var level_time = float(parts[1])
					var spike_time = float(parts[2])
					level_data[path] = {
						"level_time": level_time,
						"spike_time": spike_time
					}
		print("Loaded Level Data: ", level_data)
		file.close()

func parse_csv(file_path: String) -> Array:
	var data = []
	var file = File.new()
	if file.open(file_path, File.READ) == OK:
		file.get_line()
		while not file.eof_reached():
			var line = file.get_line()
			if line.strip_edges() != "":
				data.append(line.split(","))
		file.close()
	return data

func initialize_logs():
	create_log(frame_log_path, "Time,PlayerID,DeltaFrames,Timestamp,Level,State,Timer,Coins,Lives,Deaths,X-Position,Y-Position,X-Velocity,Y-Velocity,TickRate")
	create_log(event_log_path, "PlayerID,Timestamp,Level,ExpectedLag,State,Timer,Coins,Lives,Deaths,X-Position,Y-Position,X-Velocity,Y-Velocity,Event")
	create_log(qoe_log_path, "PlayerID,Timestamp,Level,ExpectedLag,Event")
	create_log(summary_log_path, "Summary Log")
	
func create_log(path: String, header: String):
	var file = File.new()
	if file.open(path, File.WRITE) == OK:
		if file.get_len() == 0:
			file.store_line(header)
	file.close()
	
func log_frame(delta, total_time):
	if !init:
		return
		
	var cumulative_ms = "%.6f" % (cumulative_time)
	var tick_rate_formatted = "%.2f" % tick_rate
	var delta_ms = "%.6f" % delta
	var player_id = read_int_from_file(player_id_path)
	var datetime = OS.get_datetime()
	var micro = str(Time.get_unix_time_from_system()).split(".")
	micro = "0" if len(micro) == 1 else micro[1]
	var timestamp =  str(datetime.hour).pad_zeros(2) + ":" + str(datetime.minute).pad_zeros(2) + ":" + str(datetime.second).pad_zeros(2) + "." + micro
	var current_level_path = $"/root/Global".current_level_path
	var level_parts = current_level_path.split("/")
	var level_result = (level_parts[-1]).split(".")[0]
	var state = Global.player.state_machine.state
	var timer_text = $"/root/Scoreboard".timer_text.text
	var timer_float = "%.6f" % (float(timer_text) - float(cumulative_time))
	
#	print("Timer Text:", $"/root/Scoreboard".timer_text.text)

	var coins = str($"/root/Scoreboard".coins_text.text)
	var lives = str($"/root/Scoreboard".lives_text.text)
	var deaths = str($"/root/Scoreboard".number_of_deaths)
	var x_position = str(Global.player.get_position()).split("(")[1].split(",")[0]
	var y_position = str(Global.player.get_position()).split(",")[1].split(")")[0].split(" ")[1]
	var x_velocity = str(Global.player.velocity).split("(")[1].split(",")[0]
	var y_velocity = str(Global.player.velocity).split(",")[1].split(")")[0].split(" ")[1]
	var tick_rate = str(Engine.iterations_per_second)
	
	var frame_message = str(cumulative_ms) + "," + str(player_id) + "," + str(delta_ms) + "," + timestamp + "," + level_result + "," + state + "," + str(timer_float) + "," + coins + "," + lives + "," + deaths + "," + x_position + "," + y_position + "," + x_velocity + "," + y_velocity + "," + tick_rate_formatted
	frame_logs.append(frame_message)
	if !frame_logs_by_round.has(current_round):
		frame_logs_by_round[current_round] = []
	frame_logs_by_round[current_round].append(frame_message)
	
func summarize_frame_log(data: Array) -> Dictionary:
	var total_frames = data.size()
	
	return {
		"total_frames": total_frames,
		}

func log_event(message: String = ""):
	if !init:
		return
	
	var player_id = read_int_from_file(player_id_path)
	var datetime = OS.get_datetime()
	var micro = str(Time.get_unix_time_from_system()).split(".")
	micro = "0" if len(micro) == 1 else micro[1]
	var timestamp =  str(datetime.hour).pad_zeros(2) + ":" + str(datetime.minute).pad_zeros(2) + ":" + str(datetime.second).pad_zeros(2) + "." + micro
	var current_level_path = $"/root/Global".current_level_path
	var level_parts = current_level_path.split("/")
	var level_result = (level_parts[-1]).split(".")[0]

	var state = Global.player.state_machine.state
	var timer = str($"/root/Scoreboard".timer_text.text)
	var coins = str($"/root/Scoreboard".coins_text.text)
	var lives = str($"/root/Scoreboard".lives_text.text)
	var deaths = str($"/root/Scoreboard".number_of_deaths)
	var expected_lag = str($"/root/Scoreboard".current_level_lag_time)
	var x_position = str(Global.player.get_position()).split("(")[1].split(",")[0]
	var y_position = str(Global.player.get_position()).split(",")[1].split(")")[0].split(" ")[1]
	var x_velocity = str(Global.player.velocity).split("(")[1].split(",")[0]
	var y_velocity = str(Global.player.velocity).split(",")[1].split(")")[0].split(" ")[1]
	
	var event_message = str(player_id) + "," + timestamp + "," + level_result + "," + expected_lag + "," + state + "," + timer + "," + coins + "," + lives + "," + deaths + "," + x_position + "," + y_position + "," + x_velocity + "," + y_velocity + "," + message
	event_logs.append(event_message)
	if !event_logs_by_round.has(current_round):
		event_logs_by_round[current_round] = []
	event_logs_by_round[current_round].append(event_message)
	
func summarize_event_log(data: Array) -> Dictionary:
	var total_events = data.size()
	var total_successes = 0
	var total_deaths = 0
	var total_object_drops = 0
	var total_failures = 0
	var total_jumps = 0
	var total_left_inputs = 0
	var total_right_inputs = 0
	
	for line in data:
		if line.find("Success: Reset Checkpoint Reached") != -1:
			total_successes += 1
		elif line.find("Death") != -1:
			total_deaths += 1
		elif line.find("Failure") != -1:
			total_object_drops += 1
		elif line.find("Pressed Jump") != -1:
			total_jumps += 1
		elif line.find("Pressed Left") != -1:
			total_left_inputs += 1
		elif line.find("Pressed Right") != -1:
			total_right_inputs += 1
	
	total_failures = total_deaths + total_object_drops
	var total_inputs = total_jumps + total_left_inputs + total_right_inputs
	
	return {
		"total_events": total_events,
		"total_successes": total_successes,
		"total_deaths": total_deaths,
		"total_object_drops": total_object_drops,
		"total_failures": total_failures,
		"total_jumps": total_jumps,
		"total_left_inputs": total_left_inputs,
		"total_right_inputs": total_right_inputs,
		"total_inputs": total_inputs
	}
	
func log_qoe(message: String = ""):
	if !init:
		return
	
	var player_id = read_int_from_file(player_id_path)
	var current_level_path = $"/root/Global".current_level_path
	var level_parts = current_level_path.split("/")
	var level_result = (level_parts[-1]).split(".")[0]
	var datetime = OS.get_datetime()
	var micro = str(Time.get_unix_time_from_system()).split(".")
	var expected_lag = str($"/root/Scoreboard".current_level_lag_time)
	micro = "0" if len(micro) == 1 else micro[1]
	var timestamp =  str(datetime.hour).pad_zeros(2) + ":" + str(datetime.minute).pad_zeros(2) + ":" + str(datetime.second).pad_zeros(2) + "." + micro
	var qoe_message = str(player_id) + "," + timestamp + "," + level_result + "," + expected_lag + "," + message
	qoe_logs.append(qoe_message)
	if !qoe_logs_by_round.has(current_round):
		qoe_logs_by_round[current_round] = []
	qoe_logs_by_round[current_round].append(qoe_message)

func summarize_qoe_log(data: Array) -> Dictionary:
	var total_entries = data.size() / 2
	var total_qoe_score = 0
	var acceptable_count = 0
	for line in data:
		if line[4].begins_with("QoE Score:"):
			total_qoe_score += float(line[4].split(":")[1].strip_edges())
		elif line[4].begins_with("Acceptable?: Yes"):
			acceptable_count += 1
	return {
		"total_entries": total_entries,
		"average_qoe_score": total_entries if total_entries == 0 else total_qoe_score / total_entries,
		"acceptable_count": acceptable_count
		}
		
func log_summary(output_path: String, frame_summary: Dictionary, event_summary: Dictionary, qoe_summary: Dictionary):
	var file = File.new()
	if file.open(output_path, File.WRITE) == OK:
		file.store_line("Frame Log Summary")
		file.store_line("Total Frames: " + str(frame_summary["total_frames"]))
		file.store_line("\nEvent Log Summary")
		file.store_line("Total Events: " + str(event_summary["total_events"]))
		file.store_line("\nQoE Log Summary")
		file.store_line("Total Entries: " + str(qoe_summary["total_entries"]))
		file.store_line("Average QoE Score: " + str(qoe_summary["average_qoe_score"]))
		file.store_line("Acceptable Count: " + str(qoe_summary["acceptable_count"]))
		file.close()
	
func get_round_qoe_score(qoe_entries: Array) -> float:
	var key = "QoE Score:"
	for entry in qoe_entries:
		var index = entry.find(key)
		print(entry)
		if index != -1:
			return float(entry.substr(index + key.length(), entry.length()).strip_edges())
	return 0.0
	
func count_acceptable_qoe(qoe_entries: Array) -> int:
	var count = 0
	for entry in qoe_entries:
		if entry.split(",")[3].begins_with("Acceptable?: Yes"):
			count += 1
	return count
		
func calculate_average_frame_rate_for_round(round_number: int) -> float:
	if !frame_logs_by_round.has(round_number):
		print("No frame data found for round:", round_number)
		return 0.0
   
	var round_frames = frame_logs_by_round[round_number]
	if round_frames.size() == 0:
		return 0.0

	var total_delta_time = 0.0
	var frame_count = round_frames.size()
	
	for frame in round_frames:
		var frame_parts = frame.split(",")
		if frame_parts.size() > 2:
			total_delta_time += float(frame_parts[2])

	if total_delta_time == 0.0:
		return 0.0
	
	var average_fps = frame_count / total_delta_time
	return average_fps

func create_round_summary(round_number: int):
	if !frame_logs_by_round.has(round_number) or !event_logs_by_round.has(round_number) or !qoe_logs_by_round.has(round_number):
		print("No data found for round: ", round_number)
		return
	
	var round_frames = frame_logs_by_round[round_number]
	var round_events = event_logs_by_round[round_number]
	var round_qoe = qoe_logs_by_round[round_number]
	var round_summary = []
	var average_fps = calculate_average_frame_rate_for_round(round_number)
	var level = ""
	var level_time = Global.current_level.time
	var lag_configuration = str($"/root/Scoreboard".current_level_lag_time)
	
	var frame_summary = summarize_frame_log(round_frames)
	
	var data = frame_logs_by_round[round_number][10].strip_edges()
	var data_array = data.split(",")
	level = data_array[4]

	round_summary = {
		"average_fps": average_fps,
		"level": level,
		"lag_configuration": lag_configuration,
		"level_time": level_time
	}
	
	var event_summary = summarize_event_log(round_events)
	
	var qoe_summary = {
		"round_qoe_score": get_round_qoe_score(round_qoe),
		"acceptable_count": count_acceptable_qoe(round_qoe)
	}

	round_summaries.append({
		"round": round_number,
		"round_summary": round_summary,
		"frame_summary": frame_summary,
		"event_summary": event_summary,
		"qoe_summary": qoe_summary
	})
	print("Created summary for round %d" % round_number)
		
func create_summary_log():
	var frame_summary = summarize_frame_log(parse_csv(frame_log_path))
	var event_summary = summarize_event_log(parse_csv(event_log_path))
	var qoe_summary = summarize_qoe_log(parse_csv(qoe_log_path))
	
	log_summary(summary_log_path, frame_summary, event_summary, qoe_summary)
	
	var file = File.new()
	if file.open(summary_log_path, File.READ_WRITE) == OK:
		file.seek_end()
		for round_summary in round_summaries:
			file.store_line("\nRound " + str(round_summary["round"]) + " Summary")
			file.store_line("\nRound_Summary " + str(round_summary["round_summary"]))
			file.store_line("Frame Summary: " + str(round_summary["frame_summary"]))
			file.store_line("Event Summary: " + str(round_summary["event_summary"]))
			file.store_line("QoE Summary: " + str(round_summary["qoe_summary"]))
		file.close()

func write_to_disk():
	var file = File.new()
	if file.open(frame_log_path, File.READ_WRITE) == OK:
		file.seek_end()
		for frame_message in frame_logs:
			file.store_line(frame_message)
	file.close()
	
	if file.open(event_log_path, File.READ_WRITE) == OK:
		file.seek_end()
		for event_message in event_logs:
			file.store_line(event_message)
	file.close()
	
	if file.open(qoe_log_path, File.READ_WRITE) == OK:
		file.seek_end()
		for qoe_message in qoe_logs:
			file.store_line(qoe_message)
	file.close()
	
	frame_logs.clear()
	event_logs.clear()
	qoe_logs.clear()
	cumulative_time = 0.0
	
