extends InputPasser

signal command_signal(ID:int)
var saved_input:Dictionary={}

@onready var level=$LevelDisplay
var level_save:Save=null
var level_steps:Array[Save]=[]

# Called when the node enters the scene tree for the first time.
func _ready():
	load_level(level.defaultLevelSave,false,false,false,-1)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	return

# Input handlers and updaters

func IP_receive(input_data:Dictionary,args:Dictionary={}):
	pass

func accept_input(agentID:int,move:Vector2i):
	saved_input[agentID]=move

func play_level_audio(les:Save, mtype:String, key:String, default:String):
	var audio=les.data.get(key,default)
	IP_send_signal.emit({"audio":"audio play %s %s" % [mtype,audio]})

func handle_click(mapCoords):
	print(mapCoords)

# Loaders

func load_level(inputSaveBase:Save,_editingEnabled:bool,isFirst:bool,isUnsolved:bool,setlen:int):
	var inputSave=inputSaveBase.copy_all()
	level_save=inputSave.copy()
	level_steps.clear()
	level.load_level(inputSave)
	play_level_audio(inputSave, "music", "stop", "all")
	
	var id=inputSaveBase.get_id()
	var name=inputSaveBase.get_name()
	$LPMControl/LevelDataDisplay.text="[center]%s\n%d/%d" % [name, id, setlen]

func export_level_data():
	pass

func isUndoCheckpoint(returnData:Array[int]):
	return returnData[0]!=0

func save_undo():
	var curSave:Save=level.curSave
	var lastsave=curSave.copy()
	level_steps.append(lastsave)

func undo():
	if level_steps.is_empty():
		return
	var lastsave:Save=level_steps.pop_back()
	level.load_level(lastsave)

func reset():
	level_steps.clear()
	level.load_level(level_save.copy())
	play_level_audio(level_save, "music", "play", "macleod1")

func menu_command(ID: int):
	print("ID")
