extends Popup

signal next_level_popup_closed

func _process(delta):
	pass
	if !self.visible:
		return

	# Is there a better way to do this?
	if (
		Input.is_action_pressed("move_left") or
		Input.is_action_pressed("move_right") or
		Input.is_action_pressed("move_up") or
		Input.is_action_pressed("duck") or
		Input.is_action_pressed("jump")
		):

		Scoreboard.start_level_timer()
		get_tree().paused = false
		hide()

func _on_NextLevelButton_pressed():
	emit_signal("next_level_popup_closed")
	hide()
