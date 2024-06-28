extends Control

@export var CrosshairMode:bool=false
@export var CrosshairDirection:Vector2i=Vector2i.ZERO
# Called when the node enters the scene tree for the first time.
@onready var hairs:Dictionary={
	Vector2i(0,-1):$xm,
	Vector2i(1,0):$px,
	Vector2i(0,1):$xp,
	Vector2i(-1,0):$mx
}
func _ready():
	toggleState(CrosshairMode,CrosshairDirection,true)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func recolor(color):
	for part in self.get_children():
		for temp in part.get_children():
			temp.color=color

func toggleState(newMode,newDirection,detectChange=true):
	if newMode:
		return attentionGrabbing()
	var temp=util.rearrangeQuad(newDirection)
	if detectChange:
		if CrosshairDirection==temp and CrosshairMode==newMode:
			return
	for directionKey in hairs:
		hairs[directionKey].toggleState(false,util.dot(directionKey,temp)>0)
	CrosshairMode=newMode
	CrosshairDirection=temp

func attentionGrabbing():
	for part in self.get_children():
		part.toggleState(true,true)
