extends Popup

onready var back_button = $Panel/VBoxContainer/Back
onready var submit_button = $Panel/VBoxContainer/Submit
onready var user_id = $Panel/VBoxContainer/UserID

func _ready():
	submit_button.disabled = true

func _on_Back_pressed():
	hide()

func _on_Back_focus_entered():
	back_button.grab_focus()


func _on_Submit_focus_entered():
	submit_button.grab_focus()


func _on_Submit_pressed():
	print("User ID: ", user_id.text)
	Scoreboard.reset_player_values()
	SaveManager.new_game("res://scenes/levels/framespike/playtest.tscn")

func _on_UserID_text_changed():
	if user_id.text.is_valid_integer():
		submit_button.disabled = false
	else:
		submit_button.disabled = true

# Resets the menu to its default state.
func reset():
	user_id.text = ""
	submit_button.disabled = true


func _on_FrameStutterMenu_about_to_show():
	reset()
