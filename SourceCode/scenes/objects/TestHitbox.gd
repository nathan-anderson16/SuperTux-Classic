extends Area2D

onready var sprite = get_node_or_null("Sprite")

func _ready():
	if false: sprite.hide()

func _on_Lava_body_entered(body):
	# If the body is invincible, don't kill it
#	if body.get("invincible"):
#		if body.invincible == true: return
	print("Correct!")
	if body.has_method("lag"):
		body.lag((randi() % 10) + 5)
		return
	if body.has_method("die"):
		body.die()
