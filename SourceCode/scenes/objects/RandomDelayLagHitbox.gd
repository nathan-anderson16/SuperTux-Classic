extends Area2D

onready var sprite = get_node_or_null("Sprite")

func _ready():
	if sprite: sprite.hide()

func _on_Lava_body_entered(body):
	# If the body is invincible, don't kill it
#	if body.get("invincible"):
#		if body.invincible == true: return
	if body.has_method("enter_delay_lag_field"):
		body.enter_delay_lag_field()
		return

func _on_Lava_body_exited(body):
	# If the body is invincible, don't kill it
#	if body.get("invincible"):
#		if body.invincible == true: return
	if body.has_method("exit_delay_lag_field"):
		body.exit_delay_lag_field()
		return
