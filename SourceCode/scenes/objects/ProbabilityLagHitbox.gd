extends Area2D

onready var sprite = get_node_or_null("Sprite")

func _ready():
	if sprite: sprite.hide()

func _on_Lava_body_entered(body):
	# If the body is invincible, don't kill it
#	if body.get("invincible"):
#		if body.invincible == true: return
	print("Probability Lag Entered!")
	if body.has_method("entered_lag_field"):
		body.entered_lag_field()
		return

func _on_Lava_body_exited(body):
	# If the body is invincible, don't kill it
#	if body.get("invincible"):
#		if body.invincible == true: return
	print("Probability Lag Exited!")
	if body.has_method("exited_lag_field"):
		body.exited_lag_field()
		return
