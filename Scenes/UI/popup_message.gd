extends Control

signal ok_signal


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func show_message(message:String, ok_text:String, style_data:Dictionary={}):
	show()
	$PopupFrame/PopupWindow/message.text=message
	$PopupFrame/PopupWindow/ok.text=ok_text
	if "bg_underlay" in style_data:
		$bg.show()
		$bg.modulate=style_data["bg_underlay"]
	else:
		$bg.hide()

func hide_message():
	hide()
	ok_signal.emit()
