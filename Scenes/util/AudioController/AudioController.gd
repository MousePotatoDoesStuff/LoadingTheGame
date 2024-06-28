extends Control


var audio_dict={}
var playing={}
var bus={}
# Called when the node enters the scene tree for the first time.
func _ready():
	for music in $Music.get_children():
		audio_dict[music.name]=music
	for music in $Sound.get_children():
		audio_dict[music.name]=music
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_input_pass(input:Dictionary):
	if "audio" not in input:
		return
	get_command(input["audio"])

func get_command(command:String):
	var COM=command.split(" ")
	if len(COM)<2:
		push_error("Invalid audio command: "+command)
	if COM[0]=="audio":
		handle_audio(COM)
		return

func handle_audio(COM:Array[String]):
	if audio_dict.is_empty():
		push_error("Audio controller must be placed first!")
	var mode=COM[1]
	var sel_bus="master"
	var sel_music="None"
	if len(COM)>2:
		sel_bus=COM[2]
	if len(COM)>3:
		sel_music=COM[3]
	else:
		mode="stop"
	if sel_music not in audio_dict:
		print("%s audio not found in %s!" % [sel_music,audio_dict])
		mode="stop"
	if mode=="play":
		var sel_audio=audio_dict[sel_music]
		var cur=playing.get(sel_bus,null)
		if cur==sel_audio and "force" not in COM:
			return
		playing[sel_bus]=sel_audio
		sel_audio.play()
	elif mode=="stop":
		var sel_audio=playing[sel_bus]
		sel_audio.stop()
