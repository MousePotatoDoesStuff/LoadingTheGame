extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func show_message(message:String, ok_text:String, style_data:Dictionary={}):
	$PopupFrame/PopupWindow/message.text=message
	$PopupFrame/PopupWindow/message.text=ok_text
