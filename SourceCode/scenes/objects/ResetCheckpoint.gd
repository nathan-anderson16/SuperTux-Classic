extends Node2D

onready var sfx = $SFX
onready var animation_player = $AnimationPlayer

func _on_Area2D_body_entered(body):
	Scoreboard.add_score(100)
	print("Score: ", Scoreboard.score)
	Global.reset_level()
