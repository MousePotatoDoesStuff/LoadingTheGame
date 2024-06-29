extends Control

var level:Save=null

func _ready():
	var defaultLevelSave=Save.new(
		{"name":"LeSeFrame","halfsize":[8,8],"skip":2,"maxMoves":7},
		"",
		"AI////AI/\n/",
		"////DE/\n///",
		""
	)
	defaultLevelSave._init(
		{"name":"TestFrame","halfsize":[8,8],"skip":2,"maxMoves":7},
		"",
		"AI////AI/\n/",
		"////DE/\n///",
		""
	)
	load_level(defaultLevelSave)

func load_level(_level:Save):
	level=_level
	$LevelDisplay.load_level(level)
	var name=level.data.get("name")
	var index=level.get_id()
	$TextWindow/Name.text=str(index)+". "+name
	$TextWindow/LevelData.text=level.get_full_layout()

func save_level():
	return
