extends Control
@onready var main_menu=$MainMenu
@onready var level_player=$LevelPlayer
@onready var level_editor=$MainMenu # TODO
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
	[ENUMS.screenum.SELECTOR,level_selector],
	[ENUMS.screenum.SETTINGS,options_scene],
	[ENUMS.screenum.INTRO,intro_scene],
	[ENUMS.screenum.MANAGER,levelset_manager]
]
@onready var screen_node={}


# Called when the node enters the scene tree for the first time.
func _ready():
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
	add_child(self.screen_node[self.current])

func set_screen_by_index(new_screen_index:int,stackUp:bool=false):
	var screenvar = ENUMS.screenum.LAST if new_screen_index==-1 else screen_list[new_screen_index][0]
	set_screen(screenvar,stackUp)

func last_screen():
	set_screen()
