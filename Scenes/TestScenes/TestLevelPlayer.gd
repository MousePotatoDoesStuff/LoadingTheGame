extends Control


var levelset=SaveGroup.fromString("")
var cur=0
var best=0
# Called when the node enters the scene tree for the first time.
func _ready():
	load_level()
	pass # Replace with function body.

func load_level():
	$LevelPlayer.load_level(levelset.saves[cur],false,cur==0,cur==best)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func prev_level():
	cur-=1
	load_level()
	return

func next_level():
	cur+=1
	best=max(cur,best)
	load_level()
	return

func process_command(ID:int):
	print("TEST: Command %d" % ID)
	if ID==1:
		prev_level()
		return
	if ID==2:
		next_level()
		return
