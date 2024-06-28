@tool
extends TileMap


@export_node_path("Control") var parentPath
var nullified=false
@export var gridHalfsize:Vector2i=Vector2i(5,5)
@onready var parent=get_node(parentPath)
var lastSize:Vector2=Vector2.ZERO

func _ready():
	assert(parentPath)
	assert(parent)

func _process(delta):
	if lastSize!=parent.size:
		resize_grid()
	pass

# Converters

func global_to_map(coords:Vector2)->Vector2i:
	return self.local_to_map(self.to_local(coords))

func map_to_global(tile:Vector2i)->Vector2:
	return self.to_global(self.map_to_local(tile))

func map_to_str(coords:Vector2i):
	var int_coords:Vector2i=self.gridHalfsize+coords
	return util.array_to_str([int_coords.x,int_coords.y])

func str_to_map(address:String):
	var x=util.str_to_array(address[0])
	var y=util.str_to_array(address[0])
	var int_coords=Vector2i(x,y)
	return int_coords-self.gridHalfsize

func get_nearest_tile_coords(coords:Vector2)->Vector2:
	return self.global_to_map(self.map_to_global(coords))

func isCellInMap(tile:Vector2i):
	for i in range(2):
		if tile[i]<-self.gridHalfsize[i] or tile[i]>=self.gridHalfsize[i]:
			return false
	return true

func string_to_playhead_loc():
	return

# Base functions

func resize_grid():
	lastSize=Vector2(parent.size)
	var tilesize:Vector2=Vector2(tile_set.tile_size)
	var ratio:Vector2=Vector2(gridHalfsize)*Vector2(tilesize)*2
	var minScaleV=parent.size/ratio
	var minScale=min(minScaleV.x,minScaleV.y)
	position=parent.size/2
	scale=Vector2.ONE*minScale

func blank_space(halfsize:Vector2i=Vector2i.ZERO):
	self.clear()
	if halfsize!=Vector2i.ZERO:
		gridHalfsize=halfsize
	for i in range(-gridHalfsize[0],gridHalfsize[0]):
		for j in range(-gridHalfsize[1],gridHalfsize[1]):
			set_cell(0,Vector2i(i,j),0,Vector2i(0,0))
	self.nullified=true
	return

# Setters and getters

func set_cell_by_int(cell:Vector2i,data:int):
	set_cell(0,cell,0,Vector2i(data%4,data/4))
	return

func get_cell_int(cell:Vector2i)->int:
	if not isCellInMap(cell):
		return 0
	var data = get_cell_atlas_coords(0,cell)
	return max(0,data[0]+data[1]*4)

func toggle_move_cell(cell:Vector2i,direction:int):
	var data=get_cell_int(cell)
	data^=direction
	set_cell_by_int(cell,data)
	return

func add_paths(cell:Vector2i,data:int):
	var previous:int=get_cell_int(cell)
	previous|=data
	set_cell_by_int(cell,previous)
	return previous

func remove_paths(cell:Vector2i,data:int):
	var previous=get_cell_int(cell)
	previous&=15^data
	set_cell_by_int(cell,previous)
	return previous

func update_line(main_ind:int,start:int,end:int,axis:int,deletion=false):
	if start==end:
		return
	if start>end:
		var temp=start
		start=end
		end=temp
	var curcell=util.conditional_int_swap(Vector2i(start,main_ind),axis)
	if deletion:
		for i in range(start,end):
			remove_paths(curcell,1<<axis)
			curcell[axis]+=1
			remove_paths(curcell,4<<axis)
	else:
		for i in range(start,end):
			add_paths(curcell,1<<axis)
			curcell[axis]+=1
			add_paths(curcell,4<<axis)
	return

func add_axis(main_ind:int,rows:Array,axis):
	var cur=util.conditional_swap(Vector2i(-gridHalfsize[axis],main_ind),axis)
	var status=true
	for e in rows:
		status=not status
		if cur[axis]>=gridHalfsize[axis]:
			break
		e=min(e,gridHalfsize[axis]-cur[axis])
		if e<2:
			cur[axis]+=e
			continue
		if status:
			update_line(cur[1-axis],cur[axis],cur[axis]+e-1,axis)
		cur[axis]+=e
	return

func retrieve_axis(main_ind:int,axis):
	var cur:Vector2i=Vector2i(main_ind,main_ind)
	var status:bool=false
	var res:Array[int]=[]
	var start:int=-gridHalfsize[axis]
	var debug=""
	var conn=1<<axis
	for i:int in range(start,-start):
		cur[axis]=i
		var connections=self.get_cell_int(cur)
		if connections<0:
			connections=0
		connections&=(5<<axis)
		var i2=i
		if status:
			i2+=1
		if (connections&conn==0)==status:
			res.append(i2-start)
			start=i2
			status=not status
	return util.array_to_str(res)

func load_level(content:String,halfsize:Vector2i=Vector2i.ZERO):
	if halfsize==Vector2i.ZERO:
		halfsize=gridHalfsize
	if not self.nullified or halfsize!=gridHalfsize:
		self.blank_space(halfsize)
	var cur=""
	var skip=false
	var mainval=-halfsize[1]
	var mode=0
	for e in content:
		if e=="\n" or skip:
			if mode==1:
				break
			mode+=1
			mainval=-halfsize[0]
			skip=false
			continue
		if e!="/":
			cur+=e
			continue
		if cur:
			var arr=util.str_to_array(cur)
			cur=""
			self.add_axis(mainval,arr,mode)
		mainval+=1
		if mainval==halfsize[1-mode]:
			skip=true
	gridHalfsize=halfsize
	return

func load_level_from_array(content:Array,halfsize:Vector2i=Vector2i.ZERO):
	if halfsize==Vector2i.ZERO:
		halfsize=gridHalfsize
	if not self.nullified or halfsize!=gridHalfsize:
		self.blank_space(halfsize)
	var cur=""
	var skip=false
	var mainval
	for i in range(2):
		var cur_arr=content[i]
		mainval=-halfsize[1-i]
		for el in cur_arr:
			if el:
				var arr=util.str_to_array(el)
				self.add_axis(mainval,arr,i)
		mainval+=1
	return
	
	
func save_level():
	var res=""
	var empty_count=0
	for mode in range(2):
		empty_count=0
		for mainval in range(-gridHalfsize[1-mode],gridHalfsize[1-mode]):
			var tempres=self.retrieve_axis(mainval,mode)
			if not tempres:
				empty_count+=1
				continue
			res+=util.strmul("/",empty_count)
			res+=tempres+"/"
			empty_count=0
		res+="\n" if mode==0 else ""
	return res
