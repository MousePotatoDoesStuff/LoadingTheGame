extends Control

signal applyLevelData(data)
@export var text=""
@onready var textwindow=$ColorRect/TextEdit
@onready var savebutton=$ColorRect/Apply
@onready var exitbutton=$ColorRect/Close
@export var editable=false
# Called when the node enters the scene tree for the first time.
func _ready():
	self.write("hewwo oworld")
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_button_pressed():
	self.read()

func write(text_input:String):
	text=text_input
	textwindow.text=text
	show()
	if self.editable:
		savebutton.show()
		savebutton.position=Vector2(100,325)
		exitbutton.position=Vector2(500,325)
	else:
		savebutton.hide()
		exitbutton.position=Vector2(300,325)
	return

func read():
	text=textwindow.text
	applyLevelData.emit(textwindow.text)
	return


func _on_button_2_pressed():
	hide()
