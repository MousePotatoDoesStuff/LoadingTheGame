extends InputPasser

signal save_level_signal(level: Save)
signal exit_signal()
var level:Save=null

func _ready():
	display_error("Ready for input",Color.GREEN)
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

func display_error(text:String,color:Color=Color.RED):
	$TextWindow/ColorRect/ErrorText.clear()
	$TextWindow/ColorRect/ErrorText.push_color(color)
	$TextWindow/ColorRect/ErrorText.add_text(text)

func save_level():
	var jsvar=JSON.new()
	var error=jsvar.parse($TextWindow/LevelData.text)
	if error!=OK:
		print(error)
		display_error("JSON error "+str(error))
		return
	var rawdict=jsvar.data
	if typeof(rawdict) != TYPE_DICTIONARY:
		display_error(error)
		print("Cannot initiate with non-dictionary output!")
		return
	level=Save.initDict(rawdict)
	display_error("Level saved",Color.GREEN)
	save_level_signal.emit(level)
	return

func exit():
	exit_signal.emit()

func save_and_exit():
	save_level()
	exit()
