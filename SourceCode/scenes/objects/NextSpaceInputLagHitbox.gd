extends Area2D

onready var sprite = get_node_or_null("Sprite")

func _ready():
	if sprite: sprite.hide()

func _on_Lava_body_entered(body):
	# If the body is invincible, don't kill it
#	if body.get("invincible"):
#		if body.invincible == true: return
	print("Next Space Input Lag!")
	if body.has_method("lag_space_input"):
		Logger.log_event("Next Space Lag Enter")
		body.lag_space_input()
		return
