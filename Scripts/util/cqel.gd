@tool
extends Control


@onready var def_size=get_parent().size
@onready var def_position=position
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	scale=get_parent().size/def_size
	position=def_position*scale
