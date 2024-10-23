extends Popup

signal test_popup_closed

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var qoe_slider_val = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_SubmitButton_pressed():
	print("QoE: ", $Panel/QoeSlider.value)
	self.hide()
	emit_signal("test_popup_closed")
