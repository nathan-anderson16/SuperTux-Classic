extends Node2D

onready var sfx = $SFX
onready var animation_player = $AnimationPlayer

func _on_Area2D_body_entered(body):
	Global.reset_level()
#	Global.player.position = Global.spawn_position
#	Global.player.velocity = Vector2(0, 0)
