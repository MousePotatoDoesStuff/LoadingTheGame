extends InputPasser

signal command_signal(ID:int)
signal save_level_signal(level_save: Save)
signal exit_signal()
var saved_input:Dictionary={}

@onready var level=$LevelDisplay
var level_save:Save=null
var level_steps:Array[Save]=[]
var first_placed:Vector2i=Vector2i.ONE*9999
var mode=0
var isdelete=0

# Called when the node enters the scene tree for the first time.
func _ready():
	load_level(level.defaultLevelSave)
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
	if mode==2:
		save_undo()
		if isdelete:
			level.remove_playhead(mapCoords)
		else:
			level.apply_playhead(mapCoords,"")
		level.update_save()
		level_save=level.curSave
		level.load_level(level_save.copy())
		print(level_save.playheads)
		return
	if first_placed==Vector2i.ONE*9999:
		first_placed=mapCoords
		level.placeCrosshair(first_placed)
		return
	var isLine=util.GetV2iSimilarity(first_placed,mapCoords)
	if isLine==2:
		print("Clearing....")
		mapCoords=Vector2i.ONE*9999
	elif isLine==1:
		save_undo()
		print("Placing....")
		level.apply_line(mode,first_placed,mapCoords,isdelete,true)
		level_save=level.curSave
		level.load_level(level_save.copy())
	else:
		print("Moving....")
		pass
	print(mapCoords,"->",first_placed)
	first_placed=mapCoords
	level.placeCrosshair(first_placed)
	return

func change_mode(new_mode,new_isdelete):
	mode=new_mode
	isdelete=new_isdelete
	if new_mode==2:
		first_placed=Vector2i.ONE*9999
		level.placeCrosshair(first_placed)
		return

# Loaders

func load_level(inputSaveBase:Save):
	var inputSave=inputSaveBase.copy_all()
	level_save=inputSave.copy()
	level_steps.clear()
	level.load_level(inputSave)
	play_level_audio(inputSave, "music", "stop", "all")
	
	var id=inputSaveBase.get_id()
	var name=inputSaveBase.get_name()
	$LPMControl/LevelDataDisplay.text="[center]%s\n%s/?" % [name, id]
	return

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
	if not level_steps:
		return
	level_save=level_steps[0]
	level_steps.clear()
	level.load_level(level_save.copy())

func menu_command(ID: int):
	print("ID")

func on_save():
	save_level_signal.emit(level_save)

func on_save_and_exit():
	save_level_signal.emit(level_save)
	exit_signal.emit()
