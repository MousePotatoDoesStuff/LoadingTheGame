extends Control

@export var agentID:int=0
@export var crosshair_mode:Vector2i=Vector2i.ZERO
@export var idle_time:float=5
@onready var idle_cur=0
var cur_mode:Vector2i=Vector2i.ZERO
signal ControlSignal(agentID:int,value:Vector2i)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var last_idle=idle_cur
	idle_cur+=delta
	if idle_cur<idle_time:
		return
	if last_idle>=idle_time:
		return
	%Crosshair.toggleState(true,Vector2i.ZERO)

func SendControlSignal(value:Vector2):
	var quad=util.GetQuadDirection(value,25)
	idle_cur=0
	if crosshair_mode==quad:
		return 
	crosshair_mode=quad
	%Crosshair.toggleState(false,quad)
	ControlSignal.emit(agentID,quad)
