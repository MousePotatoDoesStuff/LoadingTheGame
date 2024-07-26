extends Button


@export var reverse=false
# Called when the node enters the scene tree for the first time.
func _ready():
	toggle_button("r" in text)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func toggle_button(delete:bool):
	var type=name.substr(4,name.length()-5)
	var status="removal" if delete!=reverse else "placement"
	text="%s %s mode" % [type,status]
