extends InputPasser
@onready var main_menu=$MainMenu
@onready var level_player=$LevelPlayer
@onready var raw_level_editor=$"Level Raw Editor"
@onready var level_editor=$Settings
@onready var level_selector=$LevelSelector
@onready var levelset_manager=$LevelSequenceEditor
@onready var intro_scene=$MainMenu
@onready var options_scene=$Settings

@onready var current=ENUMS.screenum.MAIN
@onready var stack:Array=[]

@onready var screen_list=[
	[ENUMS.screenum.MAIN,main_menu],
	[ENUMS.screenum.PLAYER,level_player],
	[ENUMS.screenum.EDITOR,level_editor],
	[ENUMS.screenum.RAWEDITOR,raw_level_editor],
	[ENUMS.screenum.SELECTOR,level_selector],
	[ENUMS.screenum.SETTINGS,options_scene],
	[ENUMS.screenum.INTRO,intro_scene],
	[ENUMS.screenum.MANAGER,levelset_manager]
]
var screen_node={}
var autoplay={}


# Called when the node enters the scene tree for the first time.
func _ready():
	autoplay[ENUMS.screenum.MAIN]="macleod1"
	for E in screen_list:
		screen_node[E[0]]=E[1]
	for el in self.screen_node.values():
		if el.get_parent() == null:
			continue
		el.show()
		remove_child(el)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func set_screen(new_screen=ENUMS.screenum.LAST,stackUp:bool=false):
	if stackUp:
		stack.append(current)
	if new_screen==ENUMS.screenum.LAST:
		new_screen=stack.pop_back()
	var curnode=self.screen_node[self.current]
	if curnode.get_parent() != null:
		remove_child(curnode)
	self.current=new_screen
	curnode=self.screen_node[self.current]
	add_child(curnode)
	if curnode.has_method("update_display"):
		curnode.update_display()
	if new_screen in autoplay:
		var audio = autoplay[new_screen]
		IP_send_signal.emit({"audio":"audio play %s %s" % ["music",audio]})

func set_screen_by_index(new_screen_index:int,stackUp:bool=false):
	var screenvar = ENUMS.screenum.LAST if new_screen_index==-1 else screen_list[new_screen_index][0]
	set_screen(screenvar,stackUp)

func last_screen():
	set_screen()

func edit_level(level:Save, israw:bool=true):
	var screenname=[ENUMS.screenum.EDITOR,ENUMS.screenum.RAWEDITOR][int(israw)]
	var screen=screen_node[screenname]
	screen.load_level(level)
	set_screen(screenname,true)

func edit_level_save(level:Save):
	if current!=ENUMS.screenum.MANAGER:
		levelset_manager.save_edit(level)
		return
	assert(false)

func from_main(screenID:int):
	var chosen=[
		ENUMS.screenum.SELECTOR,
		ENUMS.screenum.MANAGER,
		ENUMS.screenum.SETTINGS
	][screenID]
	set_screen(chosen,true)
