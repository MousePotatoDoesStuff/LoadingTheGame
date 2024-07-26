extends Button

@export var reverse=false

func toggle_button(delete:bool):
	var type=name.substr(4,name.length()-5)
	var status="removal" if delete!=reverse else "placement"
	text="%s %s mode" % [type,status]
