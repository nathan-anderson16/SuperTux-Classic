extends Control

onready var panel = $TitleContent/Panel
onready var score_label = $TitleContent/Panel/Score

func _ready():
	score_label.text = "Score: %s" % (Scoreboard.score + Scoreboard.bonus_score())
	Logger.create_summary_log()

func _process(delta):
	var window_pos = OS.window_size
	var size = panel.rect_size
	panel.rect_position = Vector2((window_pos.x - size.x) / 2, (window_pos.y - size.y) / 2)

func _on_CloseButton_pressed():
	Global.goto_title_screen()
