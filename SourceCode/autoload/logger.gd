extends Node

var log_file_path: String = "" 

func _ready():
	log_file_path = OS.get_user_data_dir() + "/logs/log.txt"
	
	var dir = Directory.new()
	if !dir.dir_exists(OS.get_user_data_dir() + "/logs"):
		dir.make_dir(OS.get_user_data_dir() + "/logs")
	
func write_log(message: String):
	
	var current_level_path = $"/root/Global".current_level_path
	var lives_text = $"/root/Scoreboard".lives_text
	var timer_text = $"/root/Scoreboard".timer_text
	var coins_text = $"/root/Scoreboard".coins_text
	var number_of_deaths = $"/root/Scoreboard".number_of_deaths
	
	var file = File.new()
	
	var error = file.open(log_file_path, File.READ_WRITE)
	if error != OK:
		print("Failed to open log file!")
		return
		
	file.seek_end()
	var datetime = OS.get_datetime()
	var micro = str(Time.get_unix_time_from_system()).split(".")[1]
	var timestamp = str(datetime.year) + "-" + str(datetime.month).pad_zeros(2) + "-" + str(datetime.day).pad_zeros(2) + " " + str(datetime.hour).pad_zeros(2) + ":" + str(datetime.minute).pad_zeros(2) + ":" + str(datetime.second).pad_zeros(2) + "." + micro
	file.store_line("[" + timestamp + "] " + message)
	
	var starter_message = "Level, Lives, Timer, Coin, Deaths"
	var log_message = ""
	
	if current_level_path:
		log_message += str(current_level_path) + ","
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

	
	file.store_line(starter_message)
	file.store_line("[" + timestamp + "] " + log_message)
	
	file.close()
