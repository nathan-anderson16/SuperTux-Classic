extends Popup

signal test_popup_closed

# Called when the node enters the scene tree for the first time.
func _ready():
	$QoEPopup/SubmitButton.hide()
	$AcceptablePopup/AcceptableSubmitButton.hide()
	$AcceptablePopup.hide()


func _on_SubmitButton_pressed():
	print("QoE: ", $QoEPopup/QoeSlider.value)
	$QoEPopup.hide()
	$AcceptablePopup.show()

func _on_QoeSlider_gui_input(event):
	# Only show the submit button when the slider is clicked
	if event is InputEventMouseButton:
		$QoEPopup/SubmitButton.show()


func _on_AcceptableSubmitButton_pressed():
	print("Acceptable: ", "No" if $AcceptablePopup/HBoxContainer/NoButton.pressed else "Yes")
	self.hide()
	emit_signal("test_popup_closed")


func _on_NoButton_pressed():
	$AcceptablePopup/AcceptableSubmitButton.show()


func _on_YesButton_pressed():
	$AcceptablePopup/AcceptableSubmitButton.show()
