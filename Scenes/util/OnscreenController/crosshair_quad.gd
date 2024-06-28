extends Control

@export var direction=Vector2.ONE
@export var extent=50.0
@export var inMotion=true
@export var motionPeriod=0.5
@onready var threshold=-1

@onready var default=position
@onready var time=0
# Called when the node enters the scene tree for the first time.
func _ready():
	if threshold<0:
		threshold=motionPeriod
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not inMotion:
		return
	time+=delta
	var state:int=int(2*time/motionPeriod)&1
	position=default+direction*extent*state

func recolor(color:Color):
	$Element.color=color

func toggleState(newState:bool,newPosition:bool):
	if newState:
		inMotion=true
		return
	inMotion=false
	position=default
	if newPosition:
		position+=direction*extent
