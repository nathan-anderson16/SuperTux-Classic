extends Node2D

onready var sfx = $SFX
onready var animation_player = $AnimationPlayer
onready var hitbox = $Area2D

func _process(delta):
	if hitbox.overlaps_body(Global.player):
		var player_velocity = sqrt(pow(Global.player.velocity.x, 2) + pow(Global.player.velocity.y, 2))
		if player_velocity < 100:
			Logger.log_event("Success: Reset Checkpoint Reached")
			Scoreboard.play_reset_checkpoint()
			Scoreboard.add_score(100)
			print("Score: ", Scoreboard.score)
			Global.spawn_position = null
			Global.reset_level()

func _on_Area2D_body_entered(body):
	pass
#	Scoreboard.add_score(100)
#	print("Score: ", Scoreboard.score)
#	Global.reset_level()
