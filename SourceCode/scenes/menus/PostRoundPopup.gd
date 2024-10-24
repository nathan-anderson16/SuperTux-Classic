extends Popup

signal test_popup_closed

# Called when the node enters the scene tree for the first time.
func _ready():
	$Panel/HBoxContainer/SubmitButton.visible = false


func _on_SubmitButton_pressed():
	print("QoE: ", $Panel/QoeSlider.value)
	self.hide()
	emit_signal("test_popup_closed")


func _on_QoeSlider_gui_input(event):
	# Only show the submit button when the slider is clicked
	if event is InputEventMouseButton:
		$Panel/HBoxContainer/SubmitButton.visible = true
