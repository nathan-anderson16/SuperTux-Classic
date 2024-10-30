extends Area2D

onready var sprite = get_node_or_null("Sprite")

func _ready():
	if false: sprite.hide()

func _on_Lava_body_entered(body):
	# If the body is invincible, don't kill it
#	if body.get("invincible"):
#		if body.invincible == true: return
	print("Random Delay!")
	if body.has_method("lag_random_delay"):
		body.lag_random_delay((randi() % 10) + 5)
		return
