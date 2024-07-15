extends Object
class_name util
# Turning around direction indices
static var charcode_base=65
static var BASELEVELS="Base Levels"
static var directions=[Vector2i.RIGHT,Vector2i.DOWN,Vector2i.LEFT,Vector2i.UP]
static var reverse_directions={
	Vector2i.RIGHT:0,
	Vector2i.DOWN:1,
	Vector2i.LEFT:2,
	Vector2i.UP:3
}
static func direction_flip(dir:int):
	return (dir<<2)%15
# Converting small numbers to/from characters
static func index_to_char(ind:int,start:int=charcode_base):
	return char(ind+start)
static func char_to_index(c:String,start:int=charcode_base)->int:
	return c.unicode_at(0)-start
static func vector_to_str(v:Vector2i,start:int=charcode_base)->String:
	return char(v.x+start)+char(v.y+start)
static func str_to_vector(s:String,start:int=charcode_base)->Vector2i:
	return Vector2i(s.unicode_at(0)-start,s.unicode_at(1)-start)
static func array_to_str(X:Array[int],start=charcode_base):
	var s=""
	for el:int in X:
		s+=char(el+start)
	return s
static func str_to_array(s,start=charcode_base):
	var X=[]
	for i in range(len(s)):
		X.append(s.unicode_at(i)-start)
	return X


# Swapping vectors depending on integer variable
static func conditional_swap(V:Vector2,v:int)->Vector2:
	return Vector2(V[1],V[0]) if v&1 else V
static func conditional_int_swap(V:Vector2i,v:int)->Vector2i:
	return Vector2i(V[1],V[0]) if v&1 else V

static func GetQuadDirection(V:Vector2,threshold:float=50)->Vector2i:
	var x=int(V.x>=threshold)-int(V.x<=-threshold)
	var y=int(V.y>=threshold)-int(V.y<=-threshold)
	return Vector2i(x,y)
static func rearrangeQuad(V:Vector2i):
	return V+Vector2i(V.y,-V.x)
static func dot(A:Vector2i,B:Vector2i):
	return A.x*B.x+A.y*B.y
static func SplitVector2i(V:Vector2i)->Array[Vector2i]:
	return [V*Vector2i.RIGHT,V*Vector2i.DOWN]

# Multiplying strings
static func strmul(element,count):
	var X=""
	for i in range(count):
		X+=element
	return X

static func json_rearrange(D:Dictionary,order:Dictionary={}):
	if order.is_empty():
		order={
			"name":0,
			"halfsize":1,
			"level":2,
			"bar":3,
			"playheads":4,
			null:9
		}
	var sequence:Array=order.values()
	sequence.sort()
	var tempdict={}
	for e in sequence:
		tempdict[e]=[]
	for e in D:
		var oID:int=order.get(e,order[null])
		tempdict[oID].append(e)
	var templist=[]
	for oID in sequence:
		for key in tempdict[oID]:
			var value=JSON.stringify(D[key], "\t")
			templist.append("\t"+JSON.stringify(key, "\t")+":"+value)
	var RES=",\n".join(templist)
	return "{\n"+RES+"\n}"

static func enumerate(L):
	var R=[]
	for i in range(len(L)):
		R.append([i,L[i]])
	return R
static func arraySum(L:Array):
	return L.reduce(func(acc, num): return acc + num)

static func findTopmostChild(node:Node,name:String):
	var lastValid=null
	while node:
		for child in node.get_children():
			if child.name==name:
				lastValid=child
		node=node.get_parent()
	return lastValid
