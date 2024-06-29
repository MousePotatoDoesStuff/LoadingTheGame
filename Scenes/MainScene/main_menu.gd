extends Control
signal startgamesignal(level,mode)
signal other_signal(screen:int)
signal quit_signal()
signal settings
@onready var playbutton=$ScreenAdjuster/PlayButton
@onready var loadbutton=$ScreenAdjuster/LoadButton
@onready var LGSbutton=$ScreenAdjuster/LGSButton
@onready var settingsbutton=$ScreenAdjuster/SettingsButton
@onready var exitbutton=$ScreenAdjuster/ExitButton

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func showLevelStatus(level_name):
	$ScreenAdjuster/PlayButton.text="Continue\n(%s)" % level_name

func startgame():
	startgamesignal.emit(-1,0)

func selectlevel():
	other_signal.emit(0)

func lgs():
	other_signal.emit(1)

func options():
	other_signal.emit(2)

func exit():
	quit_signal.emit()
