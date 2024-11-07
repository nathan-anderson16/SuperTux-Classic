extends Popup

signal test_popup_closed

onready var qoe_submit_button = $QoEPopup/SubmitButton
onready var acceptable_submit_button = $AcceptablePopup/AcceptableSubmitButton
onready var acceptable_popup = $AcceptablePopup
onready var qoe_popup = $QoEPopup
onready var qoe_slider = $QoEPopup/QoeSlider
onready var acceptable_no_button = $AcceptablePopup/NoButton

# Called when the node enters the scene tree for the first time.
func _ready():
	qoe_submit_button.hide()
	acceptable_submit_button.hide()
	acceptable_popup.hide()


func _on_SubmitButton_pressed():
	print("QoE: ", qoe_slider.value)
	qoe_popup.hide()
	acceptable_popup.show()

func _on_QoeSlider_gui_input(event):
	# Only show the submit button when the slider is clicked
	if event is InputEventMouseButton:
		qoe_submit_button.show()


func _on_AcceptableSubmitButton_pressed():
	print("Acceptable: ", "No" if acceptable_no_button.pressed else "Yes")
	self.hide()
	emit_signal("test_popup_closed")


func _on_NoButton_pressed():
	acceptable_submit_button.show()


func _on_YesButton_pressed():
	acceptable_submit_button.show()
