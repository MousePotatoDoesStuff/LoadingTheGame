extends Control

signal intsig(ID:int)


var buttons=[]
# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		buttons.append(child)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func toggleButtons(states:Array):
	# 0 = no change
	# 1 = turn on
	# 2 = turn off
	# 3 = toggle
	var n=len(states)
	if n>5:
		n=5
	for i in range(n):
		var cur=buttons[i]
		var e = states[i]
		e&=1 if cur.disabled else 2
		if e!=0:
			cur.disabled=not cur.disabled


func _on_select_level_pressed():
	intsig.emit(0)


func _on_prev_level_pressed():
	intsig.emit(1)


func _on_next_level_pressed():
	intsig.emit(2)


func _on_menu_button_pressed():
	intsig.emit(3)


func _on_exit_button_pressed():
	intsig.emit(4)
