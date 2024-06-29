extends Control
signal editSignal(index:int)
signal moveSignal(index:int)
signal copySignal(index:int)
signal deleteSignal(index:int)
signal moveUpSignal(index:int)
signal moveDnSignal(index:int)

var level:Save
@onready var load


# Called when the node enters the scene tree for the first time.
func _ready():
	var defaultLevelSave=Save.new(
		{"name":"LeSeFrame","halfsize":[8,8],"skip":2,"maxMoves":7},
		"",
		"AI////AI/\n/",
		"////DE/\n///",
		""
	)
	load_level(defaultLevelSave)
	pass # Replace with function body.

func load_level(_level:Save):
	level=_level
	$LevelDisplay.load_level(level)
	var name=level.data.get("name")
	var index=level.get_id()
	$Name.text=str(index)+". "+name

func passEdit():
	editSignal.emit(level.get_id())

func passMove():
	moveSignal.emit(level.get_id())

func passCopy():
	copySignal.emit(level.get_id())

func passDelete():
	deleteSignal.emit(level.get_id())

func passMoveUp():
	moveUpSignal.emit(level.get_id())

func passMoveDn():
	moveDnSignal.emit(level.get_id())

func get_id():
	return level.get_id()
