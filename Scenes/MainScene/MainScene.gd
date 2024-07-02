extends InputPasser
@onready var SCTRL=$ScreenController
@onready var level_data_path="res://Assets/Levels/TestLevels.txt"
@onready var save_path="res://save.txt"
var possible_levelsets=""
var levelsets=Dictionary()
var current_levelset_ID:String=util.BASELEVELS
var current_levelset=null
@onready var save_data=Dictionary()

# Called when the node enters the scene tree for the first time.
func _ready():
	load_level_group_data()
	load_save_data()
	if not self.save_data.get('opened',false):
		default_save_data()
	SCTRL.set_screen_by_index(ENUMS.screenum.MAIN,false)
	var audio=self.get_save_data([ENUMS.settings],Dictionary())
	SCTRL.options_scene.set_by_settings(audio)

func _process(_delta):
	pass

# ------------------------------------------------------------------------------------------------ #
# Level data handlers
# ------------------------------------------------------------------------------------------------ #

func check_level_group_data():
	var dir=DirAccess.get_files_at("res://")
	var check=""
	for e in dir:
		if !e.ends_with(".levelset"):
			continue
		check+=e+"|"
	return check!=self.possible_levelsets

func load_level_group_data():
	var F=null
	var content=""
	var dir=DirAccess.get_files_at("res://")
	current_levelset_ID=util.BASELEVELS
	current_levelset=SaveGroup.fromString("")
	levelsets[current_levelset_ID]=current_levelset
	levelsets[current_levelset_ID+" 2"]=current_levelset
	self.possible_levelsets+=""
	for e in dir:
		if !e.ends_with(".levelset"):
			continue
		self.possible_levelsets+=e+"|"
		F=FileAccess.open("res://"+e,FileAccess.READ)
		content=F.get_as_text()
		var newset=SaveGroup.fromString(content)
		if newset != null:
			self.levelsets[newset.name]=newset
		F.close()
	SCTRL.levelset_manager.set_levelsets(self.levelsets)
	return
# ------------------------------------------------------------------------------------------------ #
# Save data handlers
# ------------------------------------------------------------------------------------------------ #

func save_save_data():
	var F=FileAccess.open(save_path,FileAccess.WRITE)
	F.store_string(JSON.stringify(self.save_data))
	F.close()
	return
func reset_progress():
	self.save_data["levelsets_progress"]={util.BASELEVELS:{"solved":0}}
	self.save_data["selected"]=util.BASELEVELS
	self.save_save_data()
func default_save_data():
	var default_status={"solved":0}
	self.save_data={
		"opened":false,
		"selected":util.BASELEVELS,
		"levelsets_progress":{util.BASELEVELS:default_status},
		ENUMS.settings:{
			"audio":{"muted":false,"volume":100},
			"sound":{"muted":false,"volume":100},
			"music":{"muted":false,"volume":100},
			"devmode":false
		}
	}
	$ScreenController.save_data=self.save_data
	self.save_save_data()
func load_save_data():
	if not FileAccess.file_exists(save_path):
		self.default_save_data()
		return
	var F=FileAccess.open(save_path,FileAccess.READ)
	self.save_data=JSON.parse_string(F.get_as_text())
	$ScreenController.save_data=self.save_data
	F.close()
func erase_save_data_and_exit():
	self.save_data.clear()
	save_save_data()
	exit_game()
func get_save_data(path,default=null):
	var cur=self.save_data
	for e in path:
		if typeof(cur)!=typeof(self.save_data):
			return default
		cur=cur.get(e,default)
	return cur
func set_save_data(path,value):
	return set_save_data_custom(path,value)
func set_save_data_custom(path,value,shift_to="value"):
	var last="root"
	var cur=self.save_data
	var arch={last:cur}
	for e in path:
		if typeof(cur)!=typeof(self.save_data):
			arch[last]={shift_to:cur}
			cur=arch[last]
		arch=cur
		last=e
		cur=arch.get(last,Dictionary())
		arch[last]=cur
	arch[last]=value
	return cur

# ------------------------------------------------------------------------------------------------ #
# Menu swappers
# ------------------------------------------------------------------------------------------------ #

func to_menu(_choice_index=0, stackup=true):
	SCTRL.set_screen_by_index(ENUMS.screenum.MAIN, stackup)
	if not save_data["opened"]:
		save_data["opened"]=true
		self.save_save_data()
	return SCTRL.switch

func on_level_select(cursetid,level,mode):
	if cursetid == null:
		cursetid=current_levelset_ID
	current_levelset_ID=cursetid
	current_levelset=levelsets[cursetid]
	var highest=save_data["levelsets_progress"][cursetid]["solved"]
	if level==-1:
		level=highest
	level=min(level,len(current_levelset.saves)-1)
	var level_mode=[ENUMS.screenum.PLAYER,ENUMS.screenum.EDITOR][mode]
	var level_node=SCTRL.screen_node[level_mode]
	var save:Save=current_levelset.saves[level]
	SCTRL.set_screen(level_mode,true)
	level_node.load_level(save,false,level==0,level==highest)

func on_win(level):
	change_level_progress(current_levelset_ID,level,false)
	return

func change_levelset(levelset_name):
	if levelset_name not in levelsets:
		return
	current_levelset_ID=levelset_name
	current_levelset=levelsets[levelset_name]
	var last = self.change_level_progress(levelset_name,0,false)
	$ScreenController/LevelSelector.set_levels(current_levelset,last)

func change_level_progress(levelset_name,lastSolved,allowRegress=true):
	var levelset_data=get_save_data(["levelsets_progress",levelset_name])
	if levelset_data == null:
		levelset_data=Dictionary()
	var cur=levelset_data.get("solved",0)
	if allowRegress or cur<=lastSolved:
		levelset_data["solved"]=lastSolved
	self.set_save_data(["levelsets_progress",levelset_name],levelset_data)
	return lastSolved

func select_available_levels():
	$ScreenController.handle_level_selector(levelsets,current_levelset_ID)

# ------------------------------------------------------------------------------------------------ #
# Menu return handlers
# ------------------------------------------------------------------------------------------------ #

func menuhandler_levelplayer(button_ID:int):
	if button_ID==4:
		exit_game()
		return
	if button_ID==3:
		SCTRL.last_screen()
		return
	print("Pressed button %d... but it didn't work" % button_ID)

# ------------------------------------------------------------------------------------------------ #
# Special handlers
# ------------------------------------------------------------------------------------------------ #

func exit_game(exit_mode:int=0):
	if OS.has_feature('web'):
		print("Cannot exit game on web browser!")
		return
	get_tree().quit()
