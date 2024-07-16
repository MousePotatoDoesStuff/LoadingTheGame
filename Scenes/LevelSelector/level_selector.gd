extends InputPasser

@export var mode=0
signal SelectLevel(level,mode)
signal CheckSave(lsname:String)
signal backSignal
var levelsets:Dictionary={}
var curlsname=util.BASELEVELS
var levelset:SaveGroup=null
@onready var LSN=$Control/ColorRect/SelectLevelset
@onready var LVN=$Control/ColorRect/OptionButton
@onready var display=$Control/LevelDisplay

# Called when the node enters the scene tree for the first time.
func _ready():
	levelset=SaveGroup.fromString("")
	levelsets[levelset.name]=levelset
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func back():
	backSignal.emit()

func set_levelsets(in_levelsets:Dictionary,chooseSet:String=util.BASELEVELS):
	levelsets=in_levelsets
	LSN.clear()
	var selected=0
	var cur=0
	for e in levelsets:
		var lvs:SaveGroup=levelsets[e]
		if lvs.saves.size()==0:
			continue
		if e==chooseSet:
			selected=cur
		LSN.add_item(e)
		cur+=1
	LSN.select(selected)
	curlsname=chooseSet
	levelset=levelsets[curlsname]
	CheckSave.emit(curlsname)

func choose_levelset(ind:int):
	var name = LSN.get_item_text(ind)
	CheckSave.emit(name)

func set_levels(levelset:SaveGroup,last:int):
	LVN.clear()
	var L=levelset.get_choice(last)
	for e in L:
		LVN.add_item(e[1],e[0])
	var sel=LVN.selected
	if sel==-1:
		LVN.select(0)
		sel=0
	var lvs=levelset.saves[sel]
	show_level(lvs)

func show_level_from_index(index:int):
	show_level(levelset.saves[index])

func show_level(level:Save):
	display.load_level(level)

func select_level():
	var level=LVN.selected
	SelectLevel.emit(curlsname,level,mode)
