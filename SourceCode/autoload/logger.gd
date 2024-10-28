extends Node

var log_file_path: String = ""  # Path to your log file

func _ready():

	log_file_path = OS.get_user_data_dir() + "/logs/log.txt"
	
	var dir = Directory.new()
	if !dir.dir_exists(OS.get_user_data_dir() + "/logs"):
		dir.make_dir(OS.get_user_data_dir() + "/logs")

func log(message: String):
	var file = File.new()
	
	var error = file.open(log_file_path, File.WRITE)
	if error != OK:
		print("Failed to open log file!")
		return
		
	# Get the current date and time
	var datetime = OS.get_datetime()
	var timestamp = str(datetime.year) + "-" + str(datetime.month).pad_zeros(2) + "-" + str(datetime.day).pad_zeros(2) + " " + str(datetime.hour).pad_zeros(2) + ":" + str(datetime.minute).pad_zeros(2) + ":" + str(datetime.second).pad_zeros(2)
	file.store_line("[" + timestamp + "] " + message)
	file.store_line(message)
	file.close()

