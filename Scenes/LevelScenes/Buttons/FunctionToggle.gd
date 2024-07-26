extends Control

signal onSetFunction(id:int,delete:bool)
var fid=-1
var delete=false
@onready var buttons=get_children()


# Called when the node enters the scene tree for the first time.
func _ready():
	setFunction(0,false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func setFunction(new_fid,new_delete):
	if fid==new_fid and delete==new_delete:
		return
	fid=new_fid
	delete=new_delete
	for i in range(buttons.size()):
		var B=buttons[i]
		B.toggle_button(delete)
		B.disabled=fid==i

func setFid(new_fid):
	setFunction(new_fid,delete)

func setDelete(new_delete):
	setFunction(fid,new_delete)

func toggleDelete():
	setFunction(fid,not delete)
