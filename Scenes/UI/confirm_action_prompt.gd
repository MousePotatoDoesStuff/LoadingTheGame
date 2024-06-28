extends Control

signal Approved(action_name)
signal Denied(action_name)

@onready var text=$"ColorRect/Action Text"
@onready var YES=$ColorRect/Yes
@onready var NO=$ColorRect/No
@export var action_name="default"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func prepare(text_value,action_name=null):
	text.text=text_value
	if action_name != null:
		self.action_name=action_name

func PassYes():
	Approved.emit(action_name)
	hide()

func PassNo():
	Denied.emit(action_name)
	hide()
