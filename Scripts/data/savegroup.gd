class_name SaveGroup

var data:Dictionary
var name:String
var saves:Array[Save]
var next_index=0

func _init(in_data,in_saves,uni_index=0):
	self.saves=[]
	self.data=in_data
	self.name=self.data.get("name","Untitled")
	self.saves.append_array(in_saves)
	fix_indices()
func fix_indices():
	next_index=len(saves)
	for i in range(next_index):
		self.saves[i].set_id(i)
static func fromString(full_layout,uni_index=0)->SaveGroup:
	if full_layout=="":
		full_layout=SaveGroupDefault.defaultFile
	var L=JSON.parse_string(full_layout)
	var self_data=L[0]
	var rawSaves=L[1]
	var self_saves=[]
	var i=0
	for e_data in rawSaves:
		if typeof(e_data)!=27:
			return null
		var e_save:Save=Save.initDict(e_data)
		e_save.set_id(i)
		i+=1
		self_saves.append(e_save)
	return SaveGroup.new(self_data,self_saves,uni_index)
func get_choice(last:int):
	if last==-2:
		last=len(self.saves)
	last=min(last+1,len(self.saves))
	var res=[]
	for i in range(last):
		var level=self.saves[i]
		var id=level.data.get("id",-1)
		var lvname=level.data.get("name","Untitled")
		if len(lvname)>15:
			lvname=lvname.left(12)+"..."
		var display=str(id)+": "+lvname
		res.append([id,display])
	return res
func _to_string():
	var L=[self.data]
	var rawSaves=[]
	for e in self.saves:
		var s=JSON.stringify(e.data)
		s+="\n"+e.get_full_layout()
		L.append(s)
	L.append(rawSaves)
	return JSON.stringify(L)
func save():
	var F=FileAccess.open("res://"+self.name+".levelset",FileAccess.WRITE)
	F.store_string(str(self))
	F.close()
func add_element(in_el:Save,in_dex:int=-1):
	if in_dex==-1 or in_dex>=len(saves):
		in_dex=len(saves)
		saves.append(in_dex)
	saves.insert(in_dex,in_el)
	in_el.set_id(next_index)
	next_index+=1

func remove_element(in_dex:int=-1):
	if in_dex==-1 or in_dex>=len(saves):
		saves.pop_back()
	saves.remove_at(in_dex)

func swap_elements(in_first:int,in_second:int):
	if in_first==in_second:
		return false
	var first_save=saves[in_first]
	var second_save=saves[in_second]
	var first_save_id=first_save.get_id()
	var second_save_id=second_save.get_id()
	second_save.set_id(first_save_id)
	first_save.set_id(second_save_id)
	saves[in_second]=first_save
	saves[in_first]=second_save
	return true
