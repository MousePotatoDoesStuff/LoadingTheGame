extends Control
var playhead=preload("res://Scenes/util/Playheads/playhead.tscn")
signal stoppedMoving
signal clickedTile(tilepos:Vector2i)

@export var gridHalfsize:Vector2i=Vector2i(5,5)
@export var editMode=false
@onready var level=$LevelTileMap
@onready var bar=$BarTileMap
@onready var playheads:Array=[]
var takenPositions={}
var curSave:Save=null
var movingCount=0
var is_updated=true
var defaultLevelSave=Save.new(
	{"name":"Untitled Level","halfsize":[8,8],"skip":2,"maxMoves":7},
	"",
	"AI////AI/\nAG//CG/",
	"////DE/\n///",
	"AA/0,CC/1"
)
var mouseActive=false

func _ready():
	clear()
	load_level(defaultLevelSave)
	# level.set_cell_by_int(Vector2i(-5,-4),15)
	if editMode:
		%Hover.show()

func _process(_delta):
	if not editMode:
		%Hover.hide()
		return
	%Hover.show()
	var mouseCoords = get_global_mouse_position()
	var mapCoords = $LevelTileMap.global_to_map(mouseCoords)
	placeCrosshair(mapCoords,true)
	if not $LevelTileMap.isCellInMap(mapCoords):
		return
	var newMouse=Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	if mouseActive and not newMouse:
		clickedTile.emit(mapCoords)
	mouseActive=newMouse
func placeCrosshair(mapCoords,ishover=false):
	var chosen=%Hover if ishover else %Clicked
	if not $LevelTileMap.isCellInMap(mapCoords):
		chosen.hide()
		return
	chosen.show()
	var reverseCoords = $LevelTileMap.map_to_local(mapCoords)
	if chosen.position==reverseCoords:
		return
	chosen.position=reverseCoords
	if chosen==%Clicked:
		return


func get_all_moves(mode:int):
	for i in range(-gridHalfsize[1],gridHalfsize[1]):
		var s=""
		for j in range(-gridHalfsize[0],gridHalfsize[0]):
			var n=0
			if mode==0:
				n=level.get_cell_int(Vector2i(j,i))
			elif mode==1:
				n=get_moves(Vector2i(j,i))
			s+=util.index_to_char(n)

func clear():
	level.blank_space()
	bar.blank_space()
	for e in self.playheads:
		e.queue_free()
		e.hide()
	self.playheads=[]
	self.takenPositions={}
	return

func load_level(level_data:Save):
	is_updated=true
	gridHalfsize=level_data.halfsize
	self.curSave=level_data
	self.clear()
	level.load_level(level_data.space_layout,gridHalfsize)
	bar.load_level(level_data.bar_layout,gridHalfsize)
	self.playheads=[]
	takenPositions={}
	for data:String in level_data.get_playheads():
		var coords:Vector2i=util.str_to_vector(data)-gridHalfsize
		apply_playhead(coords,data.substr(3))

func update_save():
	curSave.space_layout=level.save_level()
	curSave.bar_layout=bar.save_level()
	var ph_ret:Array[String]=[]
	for i in range(len(playheads)):
		var head=playheads[i]
		var headpos=bar.local_to_map(head.position)
		var pos=util.vector_to_str(headpos+gridHalfsize)
		var data=head.data.split("/")
		data[0]=pos
		var X:String="/".join(data)
		assert(typeof(X)==typeof("string"))
		ph_ret.append(X)
	curSave.set_playheads(ph_ret)
	is_updated=true
	return

func save_level():
	if not is_updated:
		update_save()
	return curSave.copy()


func apply_line(type:int,start:Vector2i,end:Vector2i,deletion:bool,updateSave:bool=true):
	var axisData=0
	for i in range(2):
		if start[i]!=end[i]:
			axisData+=i+1
	if axisData%3==0:
		return
	axisData-=1
	var mesh=[level,bar][type]
	mesh.update_line(start[1-axisData],start[axisData],end[axisData],axisData,deletion)
	if updateSave and curSave:
		var data=mesh.save_level()
		if type==0:
			curSave.space_layout=data
		elif type==1:
			curSave.bar_layout=data

func apply_playhead(pos:Vector2i, data:String, force:bool=false):
	if not force and pos in takenPositions:
		return false
	var newpos=bar.map_to_local(pos)
	var head=playhead.instantiate()
	self.takenPositions[pos]=self.playheads.size()
	self.playheads.append(head)
	bar.add_child(head)
	head.position=newpos
	head.endMotion.connect(finalise_move)
	head.apply_data(data)
	return true

func remove_playhead(pos:Vector2i):
	if pos not in takenPositions:
		return
	var curind=takenPositions[pos]
	var head=playheads[curind]
	head.queue_free()
	head.hide()
	if curind+1==playheads.size():
		playheads.pop_back()
		return
	var replacement=playheads.pop_back()
	playheads[curind]=replacement
	var repl_abs_pos=replacement.position
	var replpos=bar.local_to_map(repl_abs_pos)
	takenPositions[replpos]=curind
	return

func move_playhead(head,dirindex:int):
	var loc:Vector2i=bar.local_to_map(head.position)
	bar.toggle_move_cell(loc,1<<dirindex)
	loc+=util.directions[dirindex]
	var destination=bar.map_to_local(loc)
	head.move(destination,dirindex)

func finalise_move(loc:Vector2,direction:int):
	var cell:Vector2i=bar.local_to_map(loc)
	bar.toggle_move_cell(cell,util.direction_flip(direction))
	movingCount-=1
	if movingCount==0:
		stoppedMoving.emit()

func get_moves(movepos:Vector2i):
	if not level.isCellInMap(movepos):
		return 0
	var levelSides=level.get_cell_int(movepos) # Sides with 
	var barSides=bar.get_cell_int(movepos)
	for i in range(4):
		var e=1<<i
		if levelSides&e==0:
			continue
		if barSides&e!=0:
			continue
		if bar.get_cell_int(movepos+util.directions[i])!=0:
			levelSides^=e
	return levelSides

func get_playhead_dict()->Dictionary:
	var D=Dictionary()
	for head in playheads:
		var loc:Vector2i=bar.local_to_map(head.position)
		D[loc]=head
	return D

func process_move_express(move:int):
	var D=get_playhead_dict()
	var L=[]
	for e in D:
		L.append(e)
	var M=process_move(D,L,util.directions[move])

func process_move(objects:Dictionary,moving,direction:Vector2i):
	var M=move_checker.find_nex(objects,moving,direction)
	for L in M:
		pass
	return M

func step(agent_moves:Array[Vector2i])->Array[int]:
	is_updated=false
	var moves:Dictionary=Dictionary()
	# Create entries for every move direction used
	var returnData:Array[int]=[]
	for e in agent_moves:
		for em in util.SplitVector2i(e):
			var L:Array[Vector2i]=[]
			moves[em]=L
		returnData.append(0)
	var ph_d=get_playhead_dict()
	# pront(ph_d)
	# Sort playheads into entries according to their agent
	for loc in ph_d:
		var head=ph_d[loc]
		var move:Vector2i=agent_moves[head.agent]
		for itemised_move:Vector2i in util.SplitVector2i(move):
			var L:Array[Vector2i]=moves[itemised_move]
			L.append(loc)
	for i in range(len(util.directions)):
		var dir=1<<i
		var move=util.directions[i]
		if move not in moves:
			continue
		var M=process_move(ph_d,moves[move],move)
		for L:Array in M:
			var last=L.pop_back()
			while not L.is_empty():
				var cur:Vector2i=L.pop_back()
				var cur_head=ph_d[cur]
				if cur_head == null:
					break
				var can_move=get_moves(cur)
				if can_move&dir==0:
					break
				ph_d[last]=null
				move_playhead(cur_head,i)
				returnData[cur_head.agent]+=1
				movingCount+=1
				ph_d.erase(cur)
	return returnData

func isTileWinning(cell:Vector2i):
	var val=level.get_cell_int(cell)
	if val==0 or val&(val-1)!=0:
		return false
	var val2=bar.get_cell_int(cell)
	if val!=val2:
		return false
	return true

func getPlayheads(hid_list:Array[int]=[]):
	var head_list=[]
	for e in hid_list:
		head_list.append(playheads[e])
	return head_list

func arePlayheadsWinning(head_list:Array):
	if head_list.is_empty():
		head_list=playheads
	for head in head_list:
		var headpos=bar.local_to_map(head.position)
		var isWinning=isTileWinning(headpos)
		if not isWinning:
			return false
	return true

func isWin(agents:Dictionary={}):
	if agents.is_empty():
		return arePlayheadsWinning([])
	var head_list=[]
	for head in playheads:
		if head.agent in agents:
			head_list.append(head)
	return arePlayheadsWinning(head_list)

func getHalfsize():
	return $LevelTileMap.gridHalfsize
