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
var tux_file: Node = null
var previous_state = ""
var init = false

func _ready():
	
	set_process(true)
	set_process_input(true)
	
	var datetime = OS.get_datetime()
	var log_title_timestamp = str(datetime.year) + "-" + str(datetime.month).pad_zeros(2) + "-" + str(datetime.day).pad_zeros(2) + "_" + str(datetime.hour).pad_zeros(2) + "-" + str(datetime.minute).pad_zeros(2) + "-" + str(datetime.second).pad_zeros(2)
	
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
	if is_instance_valid(Global.player) and Global.player.has_node("state_machine"):
		var state_machine = Global.player.get_node("state_machine") if Global.player.has_node("state_machine") else null
		if state_machine != null:
			var current_state = state_machine.state
			log_frame(delta)
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

func get_event_log_path() -> String:
	return event_log_path

func initialize_logs():
	create_log(frame_log_path, "PlayerID,DeltaFrames,Timestamp,Level,State,Timer,Coins,Lives,Deaths,X-Position,Y-Position,X-Velocity,Y-Velocity,FPS,TickRate")
	create_log(event_log_path, "PlayerID,Timestamp,Level,State,Timer,Coins,Lives,Deaths,Event")
	create_log(qoe_log_path, "PlayerID,Timestamp,Level,Event")
	create_log(summary_log_path, "Summary Log")
	
func create_log(path: String, header: String):
	var file = File.new()
	if file.open(path, File.WRITE) == OK:
		if file.get_len() == 0:
			file.store_line(header)
	file.close()
	
func log_frame(delta):
	if !init:
		return
		
	var delta_ms = "%.6f" % (delta * 1000)
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
	var x_position = str(Global.player.get_position()).split("(")[1].split(",")[0]
	var y_position = str(Global.player.get_position()).split(",")[1].split(")")[0].split(" ")[1]
	var x_velocity = str(Global.player.velocity).split("(")[1].split(",")[0]
	var y_velocity = str(Global.player.velocity).split(",")[1].split(")")[0].split(" ")[1]
	var fps = str(Engine.get_frames_per_second())
	var tick_rate = str(Engine.iterations_per_second)
	
	var frame_message = str(player_id) + "," + delta_ms + "," + timestamp + "," + level_result + "," + state + "," + timer + "," + coins + "," + lives + "," + deaths + "," + x_position + "," + y_position + "," + x_velocity + "," + y_velocity + "," + fps + "," + tick_rate
	frame_logs.append(frame_message)
	if !frame_logs_by_round.has(current_round):
		frame_logs_by_round[current_round] = []
	frame_logs_by_round[current_round].append(frame_message)
	
func summarize_frame_log(data: Array) -> Dictionary:
	var total_frames = data.size()
	var total_fps = 0
	var total_tick_rate = 0
	for line in data:
		total_fps += float(line[13]) 
		total_tick_rate += float(line[14]) 
	return {
		"total_frames": total_frames,
		"average_fps": total_fps / total_frames,
		"average_tick_rate": total_tick_rate / total_frames
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
	
	var event_message = str(player_id) + "," + timestamp + "," + level_result + "," + state + "," + timer + "," + coins + "," + lives + "," + deaths + "," + message
	event_logs.append(event_message)
	if !event_logs_by_round.has(current_round):
		event_logs_by_round[current_round] = []
	event_logs_by_round[current_round].append(event_message)
	
func summarize_event_log(data: Array) -> Dictionary:
	var total_events = data.size()
	return {
		"total_events": total_events,
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
	micro = "0" if len(micro) == 1 else micro[1]
	var timestamp =  str(datetime.hour).pad_zeros(2) + ":" + str(datetime.minute).pad_zeros(2) + ":" + str(datetime.second).pad_zeros(2) + "." + micro
	var qoe_message = str(player_id) + "," + timestamp + "," + level_result + "," + message
	qoe_logs.append(qoe_message)
	if !qoe_logs_by_round.has(current_round):
		qoe_logs_by_round[current_round] = []
	qoe_logs_by_round[current_round].append(qoe_message)

func summarize_qoe_log(data: Array) -> Dictionary:
	var total_entries = data.size() / 2
	var total_qoe_score = 0
	var acceptable_count = 0
	for line in data:
		if line[3].begins_with("QoE Score:"):
			total_qoe_score += float(line[3].split(":")[1].strip_edges())
		elif line[3].begins_with("Acceptable?: Yes"):
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
		file.store_line("Average FPS: " + str(frame_summary["average_fps"]))
		file.store_line("Average Tick Rate: " + str(frame_summary["average_tick_rate"]))
		file.store_line("\nEvent Log Summary")
		file.store_line("Total Events: " + str(event_summary["total_events"]))
		file.store_line("\nQoE Log Summary")
		file.store_line("Total Entries: " + str(qoe_summary["total_entries"]))
		file.store_line("Average QoE Score: " + str(qoe_summary["average_qoe_score"]))
		file.store_line("Acceptable Count: " + str(qoe_summary["acceptable_count"]))
		file.store_line("Round Data: " + str(level_data))
		file.close()
		
func get_round_frames(frame_log, current_round):
	if frame_log == null:
		return []
	var round_frames = []
	for frame in frame_log:
		if frame.round_id == current_round: 
			round_frames.append(frame)
		return round_frames
		
func get_round_events(event_log, current_round):
	var round_events = []
	for event in event_log:
		if event.round_id == current_round:
			round_events.append(event)
	return round_events
	
func get_round_qoe_score(qoe_entries: Array) -> float:
	for entry in qoe_entries:
		if entry.split(",")[3].begins_with("QoE Score:"):
			return float(entry.split(":")[1].strip_edges())
	return 0.0
	
func calculate_min_fps(frames: Array) -> float:
	if frames == null or frames.size() == 0:
		return 0.0
	var min_fps = INF
	for frame in frames:
		var fps = float(frame.split(",")[13])
		min_fps = min(min_fps, fps)
	return min_fps

func calculate_min_tick_rate(frames: Array) -> float:
	if frames == null or frames.size() == 0:
		return 0.0
	var min_tick_rate = INF
	for frame in frames:
		var tick_rate = float(frame.split(",")[14])
		min_tick_rate = min(min_tick_rate, tick_rate)
	return min_tick_rate
	
func calculate_average_fps(frames: Array) -> float:
	if frames == null or frames.size() == 0:
		return 0.0
	var total_fps = 0.0
	for frame in frames:
		var fps = float(frame.split(",")[13]) 
		total_fps += fps
	return total_fps / frames.size()

func calculate_average_tick_rate(frames: Array) -> float:
	if frames == null or frames.size() == 0:
		return 0.0
	var total_tick_rate = 0.0
	for frame in frames:
		var tick_rate = float(frame.split(",")[14]) 
		total_tick_rate += tick_rate
	return total_tick_rate / frames.size()
	
func count_acceptable_qoe(qoe_entries: Array) -> int:
	var count = 0
	for entry in qoe_entries:
		if entry.split(",")[3].begins_with("Acceptable?: Yes"):
			count += 1
	return count
		
func create_round_summary(round_number: int):
	if !frame_logs_by_round.has(round_number) or !event_logs_by_round.has(round_number) or !qoe_logs_by_round.has(round_number):
		print("No data found for round: ", round_number)
		return
	
	var round_frames = frame_logs_by_round[round_number]
	var round_events = event_logs_by_round[round_number]
	var round_qoe = qoe_logs_by_round[round_number]
	
	var frame_summary = {
		"total_frames": round_frames.size(),
		"min_fps": calculate_min_fps(round_frames),
		"average_fps": calculate_average_fps(round_frames),
		"min_tick_rate": calculate_min_tick_rate(round_frames),
		"average_tick_rate": calculate_average_tick_rate(round_frames),
	}
	var event_summary = {
		"total_events": round_events.size(),
	}
	var qoe_summary = {
		"round_qoe_score": get_round_qoe_score(round_qoe),
		"acceptable_count": count_acceptable_qoe(round_qoe)
	}

	round_summaries.append({
		"round": round_number,
		"frame_summary": frame_summary,
		"event_summary": event_summary,
		"qoe_summary": qoe_summary
	})
	print("Created summary for round %d" % round_number)
		
func create_summary_log():
	var frame_data = parse_csv(frame_log_path)
	var event_data = parse_csv(event_log_path)
	var qoe_data = parse_csv(qoe_log_path)
	
	var frame_summary = summarize_frame_log(frame_data)
	var event_summary = summarize_event_log(event_data)
	var qoe_summary = summarize_qoe_log(qoe_data)
	
	log_summary(summary_log_path, frame_summary, event_summary, qoe_summary)
	
	var file = File.new()
	if file.open(summary_log_path, File.READ_WRITE) == OK:
		file.seek_end()
		for round_summary in round_summaries:
			file.store_line("\nRound " + str(round_summary["round"]) + " Summary")
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
	
