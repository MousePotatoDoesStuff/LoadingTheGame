extends Control

var AUDIOPATH="res://Assets/Audio/"
var audio_dict={}
var musicPlaying=null
var bus={}
var players={}
# Called when the node enters the scene tree for the first time.
func _ready():
	players={
		'music':$MusicPlayer,
		'sound':$SoundPlayer
	}
	import_audio_files()
	play_audio_file('blipSelect','music')

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
	$MusicPlayer.stream=load(file_path)
	$MusicPlayer.play()

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
		var cur=null
		if cur==sel_audio and "force" not in COM:
			return
		var islooping=sel_bus in ['music']
		if "loop" in COM:
			islooping=true
		if "noloop" in COM:
			islooping=false
		print("Play")
	elif mode=="stop":
		print("Stop")

func checkLoop(source:String):
	pass

func test():
	print("TEST")
