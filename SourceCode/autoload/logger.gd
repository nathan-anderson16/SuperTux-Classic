extends Node

var log_file_path: String = "" 
onready var lives_text = $Control/LifeCounter/Lives

func _ready():
	log_file_path = OS.get_user_data_dir() + "/logs/log.txt"
	
	var dir = Directory.new()
	if !dir.dir_exists(OS.get_user_data_dir() + "/logs"):
		dir.make_dir(OS.get_user_data_dir() + "/logs")
	
func write_log(message: String):
	var file = File.new()
	
	var error = file.open(log_file_path, File.READ_WRITE)
	if error != OK:
		print("Failed to open log file!")
		return
		
	file.seek_end()
	var datetime = OS.get_datetime()
	var timestamp = str(datetime.year) + "-" + str(datetime.month).pad_zeros(2) + "-" + str(datetime.day).pad_zeros(2) + " " + str(datetime.hour).pad_zeros(2) + ":" + str(datetime.minute).pad_zeros(2) + ":" + str(datetime.second).pad_zeros(2) + "." + str(OS.get_ticks_msec() % 1000).pad_zeros(3)
	file.store_line("[" + timestamp + "] " + message)
	
	var log_message = ""
	
	if lives_text:
		log_message += " Lives Text: " + lives_text.text
	else:
		log_message += " Lives Text node is null"
	
	file.store_line("[" + timestamp + "] " + log_message)
	
	file.close()
