extends Control

signal returntomenu
signal ResetData
signal ResetGame
signal PassOptionsSignal(path,value)
signal SaveOptionsSignal
var updated_settings={}
@onready var buses={
	"audio":AudioServer.get_bus_index("Master"),
	"music":AudioServer.get_bus_index("Music"),
	"sound":AudioServer.get_bus_index("Sound")
}
@onready var controls={
	"audio":$Control/AudioControl,
	"sound":$Control/SoundControl,
	"music":$Control/MusicControl
}

@onready var CAP=$Control/ConfirmActionPrompt
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if len(updated_settings)!=0:
			$Control/ping.play()
			for name in updated_settings:
				PassOptionsSignal.emit([ENUMS.settings,name],self.updated_settings[name])
			SaveOptionsSignal.emit()
		updated_settings={}
	pass

func set_by_settings(data):
	for name in data:
		if name in buses:
			print(">>>",name,data[name])
			controls[name].set_parsed_data(data[name])
			PassAudio(name,data[name])

func PassAudio(name,data):
	updated_settings[name]=data
	var bus=buses[name]
	var sett=updated_settings[name]
	if sett["muted"]:
		AudioServer.set_bus_mute(bus,true)
	else:
		AudioServer.set_bus_mute(bus,false)
		AudioServer.set_bus_volume_db(bus,linear_to_db(sett['volume']/100))
	return

func rtm():
	returntomenu.emit()

func confirm(code):
	var text=["Reset save data?","Reset game and exit?"][code]
	CAP.prepare(text,code)
	CAP.show()

func commandConfirmed(code:int):
	print(code)
	if code==0:
		print("Resetting save data...")
		ResetData.emit()
	if code==1:
		print("Resetting game...")
		ResetGame.emit()
