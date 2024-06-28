extends Control
class_name InputPasser
signal IP_send_signal(data:Dictionary)
var data=Dictionary()

func IP_send():
	IP_send_signal.emit(data)
	return

func IP_receive(input_data:Dictionary,args:Dictionary={}):
	var overwrite=args.get('overwrite',true)
	var autoSend=args.get('autosend',false)
	data.merge(input_data,overwrite)
	if autoSend:
		IP_send()
