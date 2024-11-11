extends Control

onready var score_label = $TitleContent/Panel/Score

func _ready():
	score_label.text = "Score: %s" % $"/root/Scoreboard".score

func _on_CloseButton_pressed():
	Global.goto_title_screen()
