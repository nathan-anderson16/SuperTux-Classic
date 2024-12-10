extends Popup

signal next_level_popup_closed

onready var objective_label = $ObjectiveLabel
onready var objective_panel = $ObjectivePanel
onready var practice_difficulty_label = $PracticeDifficultyLabel

func _process(delta):
	if !self.visible:
		return
	
	if Global.current_level != null:
		objective_label.show()
		objective_panel.show()
		objective_label.text = "Objective: " + Global.current_level.level_objective
		if Global.current_level.level_type == Scoreboard.LEVEL_TYPE.PRACTICE_1:
			practice_difficulty_label.text = "Smoothest practice"
		elif Global.current_level.level_type == Scoreboard.LEVEL_TYPE.PRACTICE_2:
			practice_difficulty_label.text = "Choppiest practice"
		else:
			practice_difficulty_label.text = ""
	else:
		objective_label.hide()
		objective_panel.hide()
	
	if (Global.current_level.level_type == Scoreboard.LEVEL_TYPE.PRACTICE_1 or
		Global.current_level.level_type == Scoreboard.LEVEL_TYPE.PRACTICE_2):
			$Panel2.show()
			$Label2.show()
	
	else:
		$Panel2.hide()
		$Label2.hide()

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
