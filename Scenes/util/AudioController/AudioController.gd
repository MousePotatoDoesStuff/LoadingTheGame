extends Control

var AUDIOPATH="res://Assets/Audio/"
var audio_dict={}
var playing={}
var is_looping={}
var players={}
# Called when the node enters the scene tree for the first time.
func _ready():
	players={
		'music':$MusicPlayer,
		'sound':$SoundPlayer
	}
	import_audio_files()
	if get_parent() == get_tree().root:
		var command="audio play music macleod1 force"
		var call=Callable(self,"get_command").bind(command)
		call.call()
		play_audio_file("macleod1","music")
		var timer=$Timer
		timer.wait_time = 1.5
		timer.one_shot=true
		timer.connect("timeout", call)
		timer.start()
	# get_command("audio play music blipSelect noloop")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func import_audio_files(filepath=AUDIOPATH):
	var dir = DirAccess.open(filepath)
	if not dir:
		print("Audio import error!")
		return
	dir.list_dir_begin()
	var file_name=dir.get_next()
	while file_name:
		if file_name.ends_with(".wav") or file_name.ends_with(".ogg") or file_name.ends_with(".mp3"):
			var full_path=filepath + "/" + file_name
			var musicname=file_name.substr(0,file_name.length()-4)
			audio_dict[musicname]=full_path
		elif dir.current_is_dir():
			import_audio_files(filepath+"/"+file_name)
		file_name = dir.get_next()
	dir.list_dir_end()

func play_audio_file(file_name:String,mode:String):
	if mode not in players:
		print('Audio mode %s invalid'.format(mode))
		return
	var player=players[mode]
	var file_path=audio_dict[file_name]
	player.stream=load(file_path)
	player.play()

func stop_audio_file(mode:String):
	if mode not in players:
		print('Audio mode %s invalid' % mode)
		return
	var player=players[mode]
	player.stop()

func get_input_pass(input:Dictionary):
	if "audio" not in input:
		return
	get_command(input["audio"])

func get_command(command:String):
	var COM=command.split(" ")
	if len(COM)<2:
		return
	if COM[0]=="audio":
		handle_audio(COM)
		return

func handle_audio(COM:Array[String]): # e.g. ["audio" "play" "music" "macleod1"]
	print(COM)
	if audio_dict.is_empty():
		push_error("Audio controller must be placed first!")
	var mode=COM[1]
	var sel_bus="audio"
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
		var cur=playing.get(sel_bus,null)
		if cur==sel_music and "force" not in COM:
			return
		var islooping=sel_bus in ['music']
		if "loop" in COM:
			islooping=true
		if "noloop" in COM:
			islooping=false
		playing[sel_bus]=sel_music
		is_looping[sel_bus]=islooping
		play_audio_file(sel_music,sel_bus)
	elif mode=="stop":
		playing[sel_bus]=null
		is_looping[sel_bus]=false
		stop_audio_file(sel_bus)

func checkLoop(source:String):
	if not is_looping.get(source,false):
		playing[source]=null
		return
	var playnow = playing.get(source, null)
	if playnow == null:
		return
	play_audio_file(playnow,source)

func test():
	print("TEST")
