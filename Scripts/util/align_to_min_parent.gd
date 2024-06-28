extends Control

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var parent_size = get_parent().size
	var ratio=parent_size/size
	print(ratio)
	var minratio=min(ratio.x,ratio.y)
	size*=minratio
	position=(parent_size-size)/2
	pass
