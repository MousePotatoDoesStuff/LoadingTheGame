extends Control

signal toMenu()

@onready var LSN=$LevelSet_List
var levelsets=null

# Called when the node enters the scene tree for the first time.
func _ready():
	var SGraw='''[{"name":"Empty"},[]]'''
	var SG=SaveGroup.fromString(SGraw)
	$ClipboardSet.arrange_elements(SG)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func toMenuFn():
	self.toMenu.emit()

func set_levelsets(LG):
	self.levelsets=LG
	LSN.clear()
	LSN.add_item("Select a levelset...")
	for e in LG:
		LSN.add_item(e)

func choose_levelset(choice_index:int):
	if choice_index==0:
		return
	var choice_name=LSN.get_item_text(choice_index)
	var levelset=self.levelsets[choice_name]
	$CurLevelSet.arrange_elements(levelset)

func load_to_clipboard(level:Save):
	$ClipboardSet.insertElement(level)

func save_from_clipboard(level:Save):
	$CurLevelSet.insertElement(level)
