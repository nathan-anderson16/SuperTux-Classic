extends Area2D

onready var sprite = get_node_or_null("Sprite")

var entry_times = {}

func _ready():
	if sprite: sprite.hide()

func _on_Lava_body_entered(body):
	var enter_time = OS.get_ticks_msec() / 1000.0 
	entry_times[body] = enter_time
	# If the body is invincible, don't kill it
#	if body.get("invincible"):
#		if body.invincible == true: return
	if body.has_method("enter_delay_lag_field"):
		body.enter_delay_lag_field()
		Logger.log_event("Random Delay Enter: Entered at time: %f" % enter_time)
		return

func _on_Lava_body_exited(body):
	if not entry_times.has(body):
		return
	
	# If the body is invincible, don't kill it
#	if body.get("invincible"):
#		if body.invincible == true: return

	var exit_time = OS.get_ticks_msec() / 1000.0  
	var enter_time = entry_times[body]
	var duration = exit_time - enter_time
	
	entry_times.erase(body)
	if body.has_method("exit_delay_lag_field"):
		body.exit_delay_lag_field()
		Logger.log_event("Random Delay Exit: Exited at time: %f, Duration: %f seconds" % [exit_time, duration])
		return
