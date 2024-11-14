extends Popup

onready var back_button = $Panel/VBoxContainer/Back
onready var submit_button = $Panel/VBoxContainer/Submit

func _on_Back_pressed():
	hide()

func _on_Back_focus_entered():
	back_button.grab_focus()


func _on_Submit_focus_entered():
	submit_button.grab_focus()


func _on_Submit_pressed():
	Global.increment_player_id()
	print("New player ID: ", Scoreboard.player_id)
	Scoreboard.reset_player_values()
	SaveManager.new_game("res://scenes/levels/framespike/playtest.tscn")
