extends InputPasser

signal command_signal(ID:int)
signal register_win()

@export var editingEnabled=false
var saved_input:Dictionary={}
var isReady=true
var isWin=false
var isUnsolved=false
var untilSkip=0
var maxMoves=0
var curMoves=0

@onready var level=$LevelDisplay
@onready var edit=$RightPlayMenu/EditButton3
var level_save:Save=null
var level_steps:Array[Save]=[]

# Called when the node enters the scene tree for the first time.
func _ready():
	# load_level(level.defaultLevelSave,false,false,false)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_UI()
	if not isReady or curMoves>=maxMoves:
		return
	isReady=false
	run_step()
	return

# Input handlers and updaters

func IP_receive(input_data:Dictionary,args:Dictionary={}):
	if "input_keys" in input_data:
		var inpk:Dictionary = input_data["input_keys"]
		var x = int(inpk.get("right",false))-int(inpk.get("up",false))
		var y = int(inpk.get("down",false))-int(inpk.get("up",false))
		var inputVector=Vector2i(x,y)
		accept_input(0,inputVector)

func accept_input(agentID:int,move:Vector2i):
	saved_input[agentID]=move

func update_UI():
	$RightPlayMenu/Skip.update(untilSkip)
	$"LevelDisplay/Out Of Moves".visible=not isWin and curMoves>=maxMoves
	$LevelDisplay/Complete.visible=isWin
	$RightPlayMenu/Continue.disabled=not isWin
	$RightPlayMenu/Moves.text="[center]Moves remaining:\n"+str(maxMoves-curMoves)

func play_level_audio(les:Save, mtype:String, key:String, default:String):
	var audio=les.data.get(key,default)
	IP_send_signal.emit({"audio":"audio play %s %s" % [mtype,audio]})

# Loaders

func update_buttons(isFirst:bool,isUnsolved:bool):
	var X = [
		1,
		2 if isFirst else 1,
		2 if isUnsolved else 1
	]
	$LPMControl/LeftPlayMenu.toggleButtons(X)

func load_level(inputSaveBase:Save,_editingEnabled:bool,isFirst:bool,isUnsolved:bool):
	var inputSave=inputSaveBase.copy_all()
	self.isUnsolved=isUnsolved
	editingEnabled=_editingEnabled
	isReady=true
	isWin=false
	update_buttons(isFirst,isUnsolved)
	print("Edit:", editingEnabled)
	edit.disabled=not editingEnabled
	untilSkip=inputSave.data.get("skip",100)
	maxMoves=inputSave.data.get("maxMoves",100)
	curMoves=0
	level_save=inputSave.copy()
	level_steps.clear()
	level.load_level(inputSave)
	play_level_audio(inputSave, "music", "play", "macleod1")

func export_level_data():
	pass

func isUndoCheckpoint(returnData:Array[int]):
	return returnData[0]!=0

func save_undo():
	var curSave:Save=level.curSave
	var lastsave=curSave.copy()
	level_steps.append(lastsave)

func run_step():
	var moves:Array[Vector2i]=[]
	for i in range(2):
		moves.append(saved_input.get(i,Vector2i.ZERO))
	var i=len(moves)
	while i in saved_input:
		moves.append(saved_input[i])
		i+=1
	var returnData:Array[int]=level.step(moves)
	if util.arraySum(returnData)==0:
		isReady=true
	else:
		IP_send_signal.emit({"audio":"audio play sound move1"})
	if isUndoCheckpoint(returnData):
		save_undo()

func finalize_step():
	var saveraw:Save=level.save_level()
	isReady=true
	isWin=level.isWin({0:0})
	if isWin:
		play_level_audio(level_save, "music", "win", "macleod1a")
		if isUnsolved:
			register_win.emit()
			isUnsolved=false
	untilSkip-=1
	curMoves+=1

func undo():
	isReady=true
	if level_steps.is_empty():
		return
	var lastsave:Save=level_steps.pop_back()
	level.load_level(lastsave)
	curMoves-=1

func reset():
	level_steps.clear()
	level.load_level(level_save.copy())
	isReady=true
	isWin=false
	curMoves=0
	play_level_audio(level_save, "music", "play", "macleod1")

func skip():
	register_win.emit()
	command_signal.emit(2)

func next_level():
	command_signal.emit(2)

func menu_command(ID: int):
	command_signal.emit(ID)
