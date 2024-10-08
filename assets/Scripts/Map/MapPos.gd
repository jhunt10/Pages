class_name MapPos

static func Parse(val)->MapPos:
	if val is Vector2i:
		return MapPos.Vector2i(val)
	if val is Vector3i:
		return MapPos.Vector3i(val)
	if val is Array:
		return MapPos.Array(val)
	if val is String:
		return MapPos.String(val)
	printerr("MapPos can not parse unknown type: %s" %[val])
	return MapPos.new(0,0)

static func Vector2i(vec:Vector2i)->MapPos:
	return MapPos.new(vec.x, vec.y, 0, 0)
	
static func Vector3i(vec:Vector3i)->MapPos:
	return MapPos.new(vec.x, vec.y, vec.z, 0)
	
static func String(val:String)->MapPos:
	var arr = JSON.parse_string(val)
	if arr is Array:
		return MapPos.Array(arr)
	else:
		printerr("Failed to parse MapPos from string '%s'" % val)
	return MapPos.new(0,0)
	
static func Array(arr:Array)->MapPos:
	if arr.size() == 2:
		return MapPos.new(arr[0], arr[1], 0, 0)
	if arr.size() == 3:
		return MapPos.new(arr[0], arr[1], arr[2], 0)
	if arr.size() == 4:
		return MapPos.new(arr[0], arr[1], arr[2], arr[3])
	printerr("Invalid array for MapPos")
	return null

var x:int
var y:int
var z:int
var dir:int

func _init(x:int, y:int, z:int=0, dir:int=0) -> void:
	self.x = x
	self.y = y
	self.z = z
	self.dir = dir

func _to_string() -> String:
	return "("+str(x)+","+str(y)+","+str(z)+":"+str(dir)+")"
