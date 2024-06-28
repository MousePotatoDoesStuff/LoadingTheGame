extends Node2D
signal ControlSignal(dir:Vector2)

var lastControl=false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var pos=Vector2.ZERO
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		pos=to_local(get_global_mouse_position())
		var apos=abs(pos)
		var ma=max(apos.x,apos.y)
		var dir=Vector2.ZERO
		if ma>150 or ma<5:
			pos=Vector2.ZERO
		if apos.x==ma:
			dir.x=1 if pos.x==apos.x else -1
		else:
			dir.y=1 if pos.y==apos.y else -1
		if ma>50:
			pos*=50/ma
		ControlSignal.emit(pos)
		lastControl=true
	else:
		if not lastControl:
			return
		lastControl=false
	ControlSignal.emit(pos)
	%Stick.position=pos
