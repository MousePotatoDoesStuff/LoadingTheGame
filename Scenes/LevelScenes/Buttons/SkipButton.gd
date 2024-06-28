extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update(untilSkip:int):
	if untilSkip>0:
		disabled=true
		text="Skip in %s moves" % [str(untilSkip)]
	else:
		disabled=false
		text="Skip"
