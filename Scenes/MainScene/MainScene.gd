extends InputPasser
const LEVELSET_FOLDER="res://Levelsets"
@onready var SCTRL=$ScreenController
@onready var level_data_path="res://Assets/Levels/TestLevels.txt"
@onready var save_path="res://save.txt"
var possible_levelsets=""
var levelsets=Dictionary()
var current_levelset_ID:String=util.BASELEVELS
var current_levelset=null
var current_level=0
@onready var save_data=Dictionary()
@onready var autoplay=$ScreenController.autoplay

# Called when the node enters the scene tree for the first time.
func _ready():
	load_save_data()
	load_level_group_data()
	if false and not self.save_data.get('opened',false):
		default_save_data()
	SCTRL.set_screen_by_index(ENUMS.screenum.MAIN,true)
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
	var dir=DirAccess.get_files_at(LEVELSET_FOLDER)
	current_levelset_ID=util.BASELEVELS
	current_levelset=SaveGroup.fromString("")
	levelsets[current_levelset_ID]=current_levelset
	self.possible_levelsets+=""
	print(current_levelset.toString())
	for e in dir:
		if !e.ends_with(".levelset"):
			continue
		self.possible_levelsets+=e+"|"
		F=FileAccess.open(LEVELSET_FOLDER+"//"+e,FileAccess.READ)
		content=F.get_as_text()
		var newset=SaveGroup.fromString(content)
		if newset != null:
			self.levelsets[newset.name]=newset
		F.close()
	var devmode=get_save_data(["settings","devmode"],false)
	SCTRL.levelset_manager.set_levelsets(self.levelsets)
	return

func save_level_group_data(levelset:SaveGroup):
	var levelset_name=levelset.name
	assert(typeof(levelset_name)==typeof("wasd"))
	levelsets[levelset_name]=levelset
	var path=LEVELSET_FOLDER+"//"+levelset_name+".levelset"
	var raw=levelset.toString()
	var F=FileAccess.open(path,FileAccess.WRITE)
	F.store_string(raw)
	F.close()
	return
	
# ------------------------------------------------------------------------------------------------ #
# Save data handlers
# ------------------------------------------------------------------------------------------------ #

func save_save_data():
	var F=FileAccess.open(save_path,FileAccess.WRITE)
	F.store_string(JSON.stringify(self.save_data, "\t"))
	F.close()
	return
func reset_progress():
	self.save_data["levelsets_progress"]={util.BASELEVELS:{"next_level":0}}
	self.save_data["selected"]=util.BASELEVELS
	self.save_save_data()
func default_save_data():
	var default_status={"next_level":0}
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
func get_save_data(path,default=null,return_default_immediately=false):
	var cur=self.save_data
	for e in path:
		if not return_default_immediately:
			return_default_immediately=typeof(cur)!=typeof(self.save_data)
		if return_default_immediately:
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

func set_autoplay():
	return

# ------------------------------------------------------------------------------------------------ #
# Menu swappers
# ------------------------------------------------------------------------------------------------ #

func to_menu(_choice_index=0, stackup=true):
	SCTRL.set_screen_by_index(ENUMS.screenum.MAIN, stackup)
	if not save_data["opened"]:
		save_data["opened"]=true
		self.save_save_data()
	return SCTRL.switch

func on_level_select(cursetid,level,mode,stackup:bool=false):
	if cursetid == null:
		cursetid=current_levelset_ID
	current_levelset_ID=cursetid
	current_levelset=levelsets[cursetid]
	var path=["levelsets_progress",cursetid,"next_level"]
	var highest=get_save_data(path,{"next_level":0},false)
	set_save_data(path,highest)
	if level==-1:
		level=highest
	level=min(level,len(current_levelset.saves)-1)
	var level_mode=[ENUMS.screenum.PLAYER,ENUMS.screenum.EDITOR][mode]
	var level_node=SCTRL.screen_node[level_mode]
	var save:Save=current_levelset.saves[level]
	SCTRL.set_screen(level_mode,stackup)
	current_level=level
	level_node.load_level(save,false,level==0,level==highest)

func next_level_from_player():
	on_win(current_level)
	var path=["levelsets_progress",current_levelset_ID,"next_level"]
	var highest=get_save_data(path,{"next_level":0},false)
	current_level+=1
	var level_mode=ENUMS.screenum.PLAYER
	var level_node=SCTRL.screen_node[level_mode]
	if current_level==len(current_levelset.saves):
		current_level=0
		SCTRL.set_screen()
		$PopupMessage.show_message("Thank you for playing!","OK",
		{'bg_underlay_inactive':Color.YELLOW})
		return
	var save:Save=current_levelset.saves[current_level]
	SCTRL.set_screen(level_mode,false)
	level_node.load_level(save,false,false,current_level==highest)

func prev_level_from_player():
	if current_level==0:
		$PopupMessage.show_message("This is the first level!","OK",
		{'bg_underlay_inactive':Color.YELLOW})
		return
	current_level-=1
	var level_mode=ENUMS.screenum.PLAYER
	var level_node=SCTRL.screen_node[level_mode]
	if current_level==len(current_levelset.saves):
		current_level=0
		SCTRL.set_screen()
		return
	var save:Save=current_levelset.saves[current_level]
	SCTRL.set_screen(level_mode,false)
	level_node.load_level(save,false,current_level==0,false)

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
	var levelset_data=get_save_data(["levelsets_progress",levelset_name],{})
	if levelset_data == null:
		levelset_data=Dictionary()
	var cur=levelset_data.get("next_level",0)
	if lastSolved==-1:
		lastSolved=cur+1
	if allowRegress or cur<=lastSolved:
		levelset_data["next_level"]=lastSolved
	self.set_save_data(["levelsets_progress",levelset_name],levelset_data)
	save_save_data()
	if lastSolved<cur and not allowRegress:
		lastSolved=cur
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
	if button_ID==2:
		next_level_from_player()
	if button_ID==1:
		prev_level_from_player()
	if button_ID==0:
		SCTRL.set_screen(ENUMS.screenum.SELECTOR,false)
	print("Pressed button %d... but it didn't work" % button_ID)

# ------------------------------------------------------------------------------------------------ #
# Special handlers
# ------------------------------------------------------------------------------------------------ #

func exit_game(exit_mode:int=0):
	if OS.has_feature('web'):
		var msg="Cannot exit game on web browser!"
		$PopupMessage.show_message(msg,"OK",{'bg_underlay_inactive':Color.YELLOW})
		print("Cannot exit game on web browser!")
		return
	get_tree().quit()
