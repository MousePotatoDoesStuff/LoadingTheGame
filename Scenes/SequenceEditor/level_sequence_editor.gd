extends InputPasser

signal toMenu()
signal editLevelSignal(level:Save, israw:bool)
signal addLevelsetSignal(levelset:SaveGroup)
signal saveSetSignal(levelset:SaveGroup)

@onready var LSN=$LevelSet_List
var levelsets=null
var curIsClipboard=false
var curIndex=-1

# Called when the node enters the scene tree for the first time.
func _ready():
	if levelsets != null:
		return
	var SGraw='''[{"name":"Empty"},[]]'''
	var SG=SaveGroup.fromString(SGraw)
	var SG2=SaveGroup.fromString(SGraw)
	SG2.name="Empty"
	SG.name="Clipboard"
	$ClipboardSet.arrange_elements(SG)
	$CurLevelSet.arrange_elements(SG2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func toMenuFn():
	self.toMenu.emit()

func set_levelsets(LG, devmode=false):
	self.levelsets=LG
	LSN.clear()
	LSN.add_item("Select a levelset...")
	for e in LG:
		var v:SaveGroup=LG[e]
		if devmode or v.is_editable():
			LSN.add_item(e)

func choose_levelset(choice_index:int):
	if choice_index==0:
		return
	var choice_name=LSN.get_item_text(choice_index)
	var levelset=self.levelsets[choice_name]
	$CurLevelSet.arrange_elements(levelset)

func save_levelset():
	var levelset=$CurLevelSet.levelset
	saveSetSignal.emit(levelset)

func load_to_clipboard(level:Save):
	$ClipboardSet.insertElement(level)

func save_from_clipboard(level:Save):
	$CurLevelSet.insertElement(level)
	var levelset=$CurLevelSet.levelset
	saveSetSignal.emit(levelset)

func on_show(data):
	$ClipboardSet.arrange_elements()
	$CurLevelSet.arrange_elements()
	

func pass_edit_direct(level:Save, israw:bool=true):
	pass_edit(level, false, israw)

func pass_edit_clipboard(level:Save, israw:bool=true):
	pass_edit(level, true, israw)

func pass_edit(level:Save, is_clipboard:bool, israw:bool=true):
	curIsClipboard=is_clipboard
	curIndex=level.get_id()
	editLevelSignal.emit(level, israw)

func save_edit(level:Save):
	if curIndex==-1:
		return
	var cur = $ClipboardSet if curIsClipboard else $CurLevelSet
	cur.setElementCovertly(level,curIndex)
	if not curIsClipboard:
		var levelset=$CurLevelSet.levelset
		saveSetSignal.emit(levelset)
