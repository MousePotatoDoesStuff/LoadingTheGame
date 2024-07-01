extends InputPasser

@export var mode=0
signal SelectLevel(level,mode)
signal CheckSave(lsID:int)
signal backSignal
var levelsets:Array[SaveGroup]=[SaveGroup.fromString("")]
var lsind=0
var levelset:SaveGroup=levelsets[0]
@onready var LSN=$Control/ColorRect/SelectLevelset
@onready var LVN=$Control/ColorRect/OptionButton
@onready var display=$Control/LevelDisplay

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func on_show(data:Dictionary):
	var levelsets=data["levelsets"]
	set_levelsets(levelsets,0)
	pass

func back():
	backSignal.emit()

func set_levelsets(in_levelsets:Array[SaveGroup],chooseSet:int=0):
	levelsets=in_levelsets
	LSN.clear()
	for i in range(len(levelsets)):
		var e:SaveGroup = levelsets[i]
		LSN.add_item(i,e.name)
	LSN.select(chooseSet)
	lsind=chooseSet
	levelset=levelsets[lsind]
	CheckSave.emit(lsind)

func set_levels(levelset:SaveGroup,last:int):
	LVN.clear()
	var L=levelset.get_choice(last)
	for e in L:
		LVN.add_item(e[1],e[0])
	show_level(levelset[LVN.selected])

func show_level_from_index(index:int):
	show_level(levelset.saves[index])

func show_level(level:Save):
	display.load_level(level)

func select_level():
	var level=LVN.selected
	SelectLevel.emit(level,mode)
