extends Node

var log_file_path: String = "" 
var tux_file: Node = null

func _ready():
	
	#var tux_file = TuxGlobal
	var datetime = OS.get_datetime()
	var log_title_timestamp = str(datetime.year) + "-" + str(datetime.month).pad_zeros(2) + "-" + str(datetime.day).pad_zeros(2) + "_" + str(datetime.hour).pad_zeros(2) + "-" + str(datetime.minute).pad_zeros(2) + "-" + str(datetime.second).pad_zeros(2)
	log_file_path = OS.get_user_data_dir() + "/logs/log_" + log_title_timestamp + ".csv"
	
	var dir = Directory.new()
	if !dir.dir_exists(OS.get_user_data_dir() + "/logs"):
		var make_dir_result = dir.make_dir(OS.get_user_data_dir() + "/logs")
		if make_dir_result != OK:
			print("Failed to create logs directory!")
	
func write_log(message: String):
	
	var current_level_path = $"/root/Global".current_level_path
	var lives_text = $"/root/Scoreboard".lives_text
	var timer_text = $"/root/Scoreboard".timer_text
	var coins_text = $"/root/Scoreboard".coins_text
	var number_of_deaths = $"/root/Scoreboard".number_of_deaths
	
	var file = File.new()
	
	var error = file.open(log_file_path, File.READ_WRITE)
	if error != OK:
		file.open(log_file_path, File.WRITE)
		print("No Log File Found, Creating A New One!")
		return
	
	file.seek_end()
	var datetime = OS.get_datetime()
	var micro = str(Time.get_unix_time_from_system()).split(".")[1]
	var timestamp = str(datetime.year) + "-" + str(datetime.month).pad_zeros(2) + "-" + str(datetime.day).pad_zeros(2) + " " + str(datetime.hour).pad_zeros(2) + ":" + str(datetime.minute).pad_zeros(2) + ":" + str(datetime.second).pad_zeros(2) + "." + micro
	
	if file.get_len() == 0:
		var header = "Timestamp,Level,Lives,Timer,Coins,Deaths"
		file.store_line(header)
	
	var log_message = timestamp + ","
	
	if current_level_path:
		var level_parts = current_level_path.split("/")
		var level_result = (level_parts[-1]).split(".")[0]
		log_message += level_result + ","
	else:
		log_message += "null,"
		
	if lives_text:
		log_message += lives_text.text + ","
	else:
		log_message += "null,"
		
	if timer_text:
		log_message += timer_text.text + ","
	else:
		log_message += "null,"
	
	if coins_text:
		log_message += coins_text.text + ","
	else:
		log_message += "null,"
	
	if number_of_deaths:
		log_message += str(number_of_deaths)
	else:
		log_message += str(0)

	file.store_line(log_message)
	file.close()
