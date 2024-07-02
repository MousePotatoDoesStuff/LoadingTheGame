extends Control


var audio_dict={}
var playing={}
var looping={}
var bus={}
# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		for node in child.get_children():
			if node is AudioStreamPlayer:
				audio_dict[node.name] = node
				var curcall=Callable(self, "checkLoop")
				var autocall=curcall.bindv([node.name])
				node.connect("finished", autocall)


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
		var islooping=sel_bus in ['music']
		if "loop" in COM:
			islooping=true
		if "noloop" in COM:
			islooping=false
		looping[sel_music]=islooping
		sel_audio.play()
	elif mode=="stop":
		var sel_audio=playing[sel_bus]
		looping[sel_bus]=false
		playing[sel_bus]=null
		sel_audio.stop()

func checkLoop(sel_music:String):
	if looping.get(sel_music,false):
		var sel_audio=audio_dict[sel_music]
		sel_audio.play()
	else:
		playing[sel_bus]=null

func test():
	print("TEST")
