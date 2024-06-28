extends Control

@export var defaultScreen=Vector2(1600,900)
@onready var defaultPosition=position
@onready var currentScreen=null
# Called when the node enters the scene tree for the first time.
func _ready():
	currentScreen = get_tree().get_root().size
	resize_to_fit(currentScreen)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var screen_size = get_tree().get_root().size
	if currentScreen!=screen_size:
		resize_to_fit(screen_size)
		currentScreen=screen_size
	pass


func resize_to_fit(screen_size):
	var hScale=screen_size[0]/defaultScreen[0]
	var vScale=screen_size[1]/defaultScreen[1]
	var minScale=min(hScale,vScale)
	# var set_width = ProjectSettings.get("display/window/size/width")
	# var set_height = ProjectSettings.get("display/window/size/height")
	# var real_size = size * screen_size / Vector2(set_width, set_height)
	scale=Vector2(minScale,minScale)
	position=defaultPosition*Vector2(hScale,vScale)
	# pront(name)
	# pront(position)
	# pront("%s %s %s"% [hScale,vScale,minScale])
	# pront()
