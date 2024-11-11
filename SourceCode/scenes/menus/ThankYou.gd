extends Control

onready var score = $TitleContent/Score

func _ready():
	score.text = "Score: %s" % $"/root/Scoreboard".score

func _on_CloseButton_pressed():
	Global.goto_title_screen()
