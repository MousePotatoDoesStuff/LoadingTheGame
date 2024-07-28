extends Control
signal moveSignal(level:Save)
signal editSignal(level:Save, israw:bool)
signal fileSaveSignal

@export var elementSize:float=300
@export var elementOffset:float=250
@onready var ctrl=$ScrollContainer/DropdownControl
var lv_template=preload("res://Scenes/LevelSelector/level_sel_frame.tscn")
var levelset:SaveGroup = null

# Called when the node enters the scene tree for the first time.
func _ready():
	if levelset == null:
		var SG=SaveGroup.fromString("")
		arrange_elements(SG)
	else:
		arrange_elements(levelset)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_signals(lv_ins):
	var lv_editGUI:Signal=lv_ins.editGUISignal
	var lv_editRaw:Signal=lv_ins.editRawSignal
	var lv_move:Signal=lv_ins.moveSignal
	var lv_copy:Signal=lv_ins.copySignal
	var lv_delete:Signal=lv_ins.deleteSignal
	var lv_moveup:Signal=lv_ins.moveUpSignal
	var lv_movedn:Signal=lv_ins.moveDnSignal
	lv_editGUI.connect(editElementGUI)
	lv_editRaw.connect(editElementRaw)
	lv_move.connect(moveElement)
	lv_copy.connect(copyElement)
	lv_delete.connect(deleteElement)
	var index=lv_ins.get_id()
	lv_moveup.connect(moveUp)
	lv_movedn.connect(moveDn)

func arrange_elements(new_levelset:SaveGroup=null):
	if new_levelset !=null:
		levelset=new_levelset
	$Header/Name.text=levelset.name
	levelset.fix_indices()
	for child in ctrl.get_children():
		ctrl.remove_child(child)
		child.queue_free()
	for i in range(len(levelset.saves)):
		var element=levelset.saves[i]
		var lv_ins=lv_template.instantiate()
		ctrl.add_child(lv_ins)
		lv_ins.position=Vector2(25,25+300*i)
		lv_ins.load_level(element)
	update_elements()
	ctrl.custom_minimum_size.y=len(levelset.saves)*300
	# instantiate new elements as written in addElement

func update_elements():
	for lv_ins in ctrl.get_children():
		set_signals(lv_ins)

func getFirstVisibleIndex():
	var sv=$ScrollContainer.scroll_vertical+elementOffset
	var element:int=int(sv/elementSize)
	return element

func addElement(element:Save,index:int=-1, existingElement=null):
	levelset.add_element(element,index)
	arrange_elements()
	fileSaveSignal.emit()

func setElementCovertly(element:Save,index:int=-1, existingElement=null):
	print(element.get_full_layout())
	levelset.set_element(element,index)

#
# Setters that need to be saved
#

func setElement(element:Save,index:int=-1, existingElement=null):
	levelset.set_element(element,index)
	arrange_elements()
	fileSaveSignal.emit()

func insertElement(element):
	var index=getFirstVisibleIndex()
	addElement(element,index)
	fileSaveSignal.emit()

func editElementGUI(elem_id):
	editSignal.emit(levelset.saves[elem_id],false)
	fileSaveSignal.emit()

func editElementRaw(elem_id):
	editSignal.emit(levelset.saves[elem_id],true)
	fileSaveSignal.emit()

func moveElement(elem_id):
	moveSignal.emit(levelset.saves[elem_id].copy())

func copyElement(elem_id):
	levelset.add_element(levelset.saves[elem_id].copy(),elem_id+1)
	arrange_elements()
	fileSaveSignal.emit()

func deleteElement(elem_id):
	levelset.remove_element(elem_id)
	arrange_elements()
	fileSaveSignal.emit()

func moveDn(elem_id):
	if elem_id+1==len(levelset.saves):
		return
	levelset.swap_elements(elem_id,elem_id+1)
	arrange_elements()
	fileSaveSignal.emit()

func moveUp(elem_id):
	if elem_id==0:
		return
	levelset.swap_elements(elem_id,elem_id-1)
	arrange_elements()
	fileSaveSignal.emit()
