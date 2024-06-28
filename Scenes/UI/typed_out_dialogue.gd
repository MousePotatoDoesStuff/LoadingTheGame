extends ColorRect

var action_queue=Deque.new()
var time=0.0
var true_text=""
var text_params=""
# Called when the node enters the scene tree for the first time.
func _ready():
	Deque.run_tests()
	set_text_layout(Vector2.ONE*10)
	set_text_params("[center]")
	type_out("Loading game...",0.1)
	pass # Replace with function body.

func set_text(true_text:String):
	$text.text=text_params+true_text

func get_text():
	var text=$text.text
	return text.substr(len(text.params))

func set_text_params(params:String):
	text_params=params
	set_text(true_text)

func set_text_layout(location:Vector2, textwindow_size:Vector2=Vector2.ZERO):
	if textwindow_size == Vector2.ZERO:
		textwindow_size=size-location*2
	$text.position=location
	$text.size=textwindow_size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time+=delta
	while true:
		var nex=action_queue.peek_left()
		if nex == null or nex[0]>time:
			return
		var val=action_queue.pop_left()
		text_step(val)

func text_step(step_data):
	var step_type=step_data[1]
	if step_type=="append":
		if len(step_data)>3:
			var ins_ind=step_data[3]
			var text=true_text.substr(0,ins_ind)
			text+=step_data[2]
			text+=true_text.substr(ins_ind)
			true_text=text
		else:
			true_text+=step_data[2]
	set_text(true_text)
	

func type_out(text: String, typing_time: float):
	for i in range(len(text)):
		action_queue.append([time+typing_time*i,'append',text[i]])
