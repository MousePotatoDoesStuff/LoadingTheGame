@tool
extends Control
signal endMotion(loc:Vector2i,direction:int)

@export var move_time:float=0.25
@onready var start=Vector2(0,0)
@onready var end=Vector2(0,0)
var dirindex=0
var agent=0
# 0 = idle
# 1 = beginning to move, signal exit
# 2 = done, signal entry
# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	updateLocation()
	pass


func apply_data(data:String):
	var dataList=data.split("|")
	if len(data)==0:
		return
	agent=int(data[0])


func updateLocation():
	var cur_move_time=$Timer.time_left
	if cur_move_time==0:
		return
	var deltapos=Vector2(start-end)
	var new_location=Vector2(end)+deltapos*(cur_move_time/move_time)
	self.position=new_location

func finishUpdate():
	self.position=end
	start=end
	endMotion.emit(position,1<<dirindex)
	return

func move(destination:Vector2,_dirindex:int,time=-1):
	if time==-1:
		time=move_time
	dirindex=_dirindex
	# var delta:Vector2=util.directions[dirindex]
	start=position
	end=destination
	$Timer.start(time)
