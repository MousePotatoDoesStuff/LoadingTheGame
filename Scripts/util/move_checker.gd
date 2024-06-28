extends Node
class_name move_checker

static func step_find_starters(objectset,moves,direction,starters,nex):
	var E = moves.pop_back()
	if E not in objectset:
		return
	var F = E+direction
	if E in starters:
		starters.erase(E)
	else:
		starters[E]=true
	if F in starters:
		starters.erase(F)
	else:
		starters[F]=true
	nex[E] = F
	moves.append(F)
	objectset.erase(E)
	return

static func find_nex(objectset_OG: Dictionary, moves:Array, direction:Vector2i):
	var objectset=objectset_OG.duplicate()
	var nex=Dictionary()
	var starters=Dictionary()
	while moves:
		step_find_starters(objectset,moves,direction,starters,nex)
	var M = []
	for E in starters:
		if E not in nex:
			continue
		var L = []
		var F = E
		while F != null:
			L.append(F)
			F = nex.get(F)
		M.append(L)
	return M
