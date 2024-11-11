extends Popup

signal next_level_popup_closed

func _on_NextLevelButton_pressed():
	emit_signal("next_level_popup_closed")
	hide()
