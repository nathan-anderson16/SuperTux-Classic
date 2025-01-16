extends Popup

var player_id_text = SpinBox.new()
var player_score_text = SpinBox.new()

onready var done = $Panel/Done
onready var restart_button = $Panel/PanelContainer/ScrollContainer/Options/Restart

onready var level_select = $Panel/PanelContainer/ScrollContainer/Options/LevelSelect
onready var practice = $Panel/PanelContainer/ScrollContainer/Options/LevelSelect/Practice
onready var row_1 = $Panel/PanelContainer/ScrollContainer/Options/LevelSelect/Row1
onready var row_2 = $Panel/PanelContainer/ScrollContainer/Options/LevelSelect/Row2
onready var row_3 = $Panel/PanelContainer/ScrollContainer/Options/LevelSelect/Row3
onready var row_4 = $Panel/PanelContainer/ScrollContainer/Options/LevelSelect/Row4

onready var player_id = $Panel/PanelContainer/ScrollContainer/Options/PlayerID
onready var player_score = $Panel/PanelContainer/ScrollContainer/Options/PlayerScore

# Called when the node enters the scene tree for the first time.
func _ready():
	# Practice levels
	var practice_1_button = Button.new()
	practice_1_button.text = "Practice 1"
	practice_1_button.rect_min_size = Vector2(50, 50)
	practice_1_button.connect("button_down", self, "_button_practice_1")
	practice.add_child(practice_1_button)
	
	var practice_2_button = Button.new()
	practice_2_button.text = "Practice 2"
	practice_2_button.rect_min_size = Vector2(50, 50)
	practice_2_button.connect("button_down", self, "_button_practice_2")
	practice.add_child(practice_2_button)
	
	_load_round_buttons()
	
	# Player ID
	player_id_text.rect_min_size = Vector2(100, 0)
	player_id_text.step = 1
	player_id_text.max_value = 10000000
	player_id_text.value = Scoreboard.player_id
	
	var player_id_save_button = Button.new()
	player_id_save_button.text = "Save"
	player_id_save_button.rect_min_size = Vector2(50, 30)
	player_id_save_button.connect("button_down", self, "_player_id_save_button_pressed")
	
	player_id.add_child(player_id_text)
	player_id.add_child(player_id_save_button)
	
	# Player Score
	player_score_text.rect_min_size = Vector2(100, 0)
	player_score_text.step = 100
	player_score_text.max_value = 10000000
	player_score_text.value = Scoreboard.score
	
	var player_score_save_button = Button.new()
	player_score_save_button.text = "Save"
	player_score_save_button.rect_min_size = Vector2(50, 30)
	player_score_save_button.connect("button_down", self, "_player_score_save_button_pressed")
	
	player_score.add_child(player_score_text)
	player_score.add_child(player_score_save_button)

func _load_round_buttons():
	for child in row_1.get_children():
		child.free()
	for child in row_2.get_children():
		child.free()
	for child in row_3.get_children():
		child.free()
	for child in row_4.get_children():
		child.free()
	
	for i in range(1, 9):
		var button = Button.new()
		button.text = str(i)
		button.rect_min_size = Vector2(50, 50)
		button.connect("button_down", self, "_button_pressed", [i])
		button.hint_tooltip = _format_tooltip(Scoreboard.ordered_round_data()[i - 1])
		row_1.add_child(button)
	
	for i in range(9, 17):
		var button = Button.new()
		button.text = str(i)
		button.rect_min_size = Vector2(50, 50)
		button.connect("button_down", self, "_button_pressed", [i])
		button.hint_tooltip = _format_tooltip(Scoreboard.ordered_round_data()[i - 1])
		row_2.add_child(button)
	
	for i in range(17, 25):
		var button = Button.new()
		button.text = str(i)
		button.rect_min_size = Vector2(50, 50)
		button.connect("button_down", self, "_button_pressed", [i])
		button.hint_tooltip = _format_tooltip(Scoreboard.ordered_round_data()[i - 1])
		row_3.add_child(button)
		
	for i in range(25, 33):
		var button = Button.new()
		button.text = str(i)
		button.rect_min_size = Vector2(50, 50)
		button.connect("button_down", self, "_button_pressed", [i])
		button.hint_tooltip = _format_tooltip(Scoreboard.ordered_round_data()[i - 1])
		row_4.add_child(button)

func _player_id_save_button_pressed():
	Scoreboard.player_id = int(player_id.get_children()[1].value)
	self._load_round_buttons()

func _player_score_save_button_pressed():
	Scoreboard.score = int(player_score.get_children()[1].value)

func _format_tooltip(round_data):
	var path = round_data["path"]
	var level_time = round_data["level_time"]
	var spike_time = round_data["spike_time"]
	var objective_text = round_data["objective_text"]
	
	var filename = path.split("/")[-1]
	return "Path: " + filename + "\nLevel Time: " + level_time + "\nSpike Time: " + spike_time + "\nObjective: " + objective_text

func _button_practice_1():
	Scoreboard.current_round = 0
	Scoreboard.goto_practice(0)

func _button_practice_2():
	Scoreboard.current_round = 0
	Scoreboard.goto_practice(1)

func _button_pressed(i):
	Scoreboard.current_round  = i - 1
	Scoreboard.load_round(Scoreboard.current_round)

func _on_Done_mouse_entered():
	done.grab_focus()

func _on_Done_pressed():
	self.hide()

func _on_Restart_mouse_entered():
	restart_button.grab_focus()

func _on_Restart_pressed():
	Global.reset_level()
