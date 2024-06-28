extends Control

signal volume_changed(name,data)

@export var title="Audio"
@export var saveas="audio"
@onready var slider=$Slider
@onready var text=$Text
@onready var reset=$Reset
var muted=false
var volume=50
var checkValid=true
# Called when the node enters the scene tree for the first time.
func _ready():
	self.update_text()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_parsed_data(data):
	muted=data.get("muted",false)
	volume=data.get("volume",100)
	self.slider.value=0 if muted else volume
	self.update_text()

func get_parsed_data():
	return {"muted":muted,"volume":volume}

func toggle_mute():
	self.checkValid=false
	if muted:
		self.slider.value=volume
	else:
		self.slider.value=0
	muted=not muted
	self.update_text()
	volume_changed.emit(self.saveas,self.get_parsed_data())
	self.checkValid=true

func checkupdate(new_value):
	if not checkValid:
		return
	if self.volume==new_value:
		return
	if new_value==0:
		self.toggle_mute()
		update_text()
		return
	self.volume=new_value
	if muted:
		muted=false
	update_text()
	volume_changed.emit(self.saveas,self.get_parsed_data())

func update_text():
	var res=str(self.volume)
	if self.muted:
		res="Muted"
	self.text.text=self.title+": "+res
	var mt="Unmute" if muted else "Mute"
	self.reset.text=mt
	return
