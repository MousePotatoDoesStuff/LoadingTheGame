class_name Save


var data:Dictionary
var halfsize:Vector2i
var space_layout:String
var bar_layout:String
var playheads:String
func _init(in_data:Dictionary,
		in_full_layout:String='',in_space_layout:String='',in_bar_layout:String='',in_playheads:String=''
	):
	if in_full_layout:
		var L=in_full_layout.split("\n")
		in_space_layout=L[0]+"\n"+L[1]
		in_bar_layout=L[2]+"\n"+L[3]
		in_playheads=L[4]
	self.data=in_data
	var HSL=data.get('halfsize',[10,10])
	self.halfsize=Vector2i(HSL[0],HSL[1])
	self.space_layout=in_space_layout
	self.bar_layout=in_bar_layout
	self.playheads=in_playheads
	return
static func initDict(D:Dictionary)->Save:
	D["name"]=D.get("name","Untitled")
	var res=Save.new(
		D,
		"",
		D.get("level",""),
		D.get("bar",""),
		D.get("playheads","")
	)
	return res
static func initRaw(raw:String)->Save:
	var json=JSON.parse_string(raw)
	assert(json!=null)
	return initDict(json)
func getDict():
	var HSL=data.get('halfsize',[10,10])
	data["level"]=space_layout
	data["bar"]=bar_layout
	data["playheads"]=playheads
	return data
func copy(new_id=null):
	var newdata=Dictionary()
	for key in self.data:
		newdata[key]=data[key]
	if new_id !=null:
		newdata["id"]=new_id
	var new=Save.new(newdata,"",self.space_layout,self.bar_layout,self.playheads)
	return new
func set_id(in_id:int):
	data["id"]=in_id
func get_id():
	return self.data.get("id","-1")
func get_idname():
	return str(get_id())+": "+self.data.get("name","Untitled")
func get_layout(is_bar_layout):
	var layout=space_layout
	if is_bar_layout:
		layout=bar_layout
	var dual=layout.split("\n")
	if len(dual)==1:
		dual.append("")
	return "\n".join(dual)
func get_layout_as_array(is_bar_layout):
	var layout=space_layout
	if is_bar_layout:
		layout=bar_layout
	var dual=layout.split("\n")
	if len(dual)==1:
		dual.append("")
	var res=[]
	for e in dual:
		res.append(e.split("/"))
	return res
func get_playheads():
	if len(playheads)<2:
		return []
	return playheads.split(",")
func set_playheads(playheads_A: Array[String]):
	self.playheads=",".join(playheads_A)
func get_full_layout()->String:
	var out_data:Dictionary=data.duplicate()
	out_data['level']=space_layout
	out_data['bar']=bar_layout
	out_data['playheads']=playheads
	return util.json_rearrange(out_data)
