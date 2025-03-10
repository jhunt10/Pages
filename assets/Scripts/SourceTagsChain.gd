class_name SourceTagChain

enum SourceTypes {Actor, Action, Missile, Effect, }

# Array of source ids in order of parent to child
var _source_order:Array = []
# Dictionary of source_id to tags for that source
var _source_tags:Dictionary = {}
var source_actor:BaseActor

func _init() -> void:
	pass

## Add a new source to the end of this chain
func append_source(type:SourceTypes, source:Object)->SourceTagChain:
	var tags = [SourceTypes.keys()[type]]
	var id = ''
	if not source: 
		print_debug("No source object provided")
		return self
		
	if source.has_method("get_tagable_id"):
		id = source.get_tagable_id()
	else:
		print_debug("No 'get_tagable_id' found on new tag source object: %s" % [source])
	
	if _source_order.has(id):
		printerr("Source Chain looped on self with id '%s': %s" % [id, _source_order] )
	
	if source.has_method("get_tags"):
		tags.append_array(source.get_tags())
	else:
		print_debug("No 'get_tags' found on new tag source object: %s" % [source])
	
	if id != '':
		_source_order.append(id)
		_source_tags[id] = tags
		if type == SourceTypes.Actor:
			if not source is BaseActor:
				printerr("Non BaseActor source provided with SourceTypes.Actor.")
			elif source_actor:
				printerr("Source Actor already set.")
			else:
				source_actor = source
	return self

## Create a copy of this chain
func copy_chain()->SourceTagChain:
	var new_chain = SourceTagChain.new()
	new_chain._source_order = _source_order.duplicate()
	new_chain._source_tags = _source_tags.duplicate(true)
	return new_chain

## Create a copy of this chain and append a new source to it
func copy_and_append(type:SourceTypes, source:Object)->SourceTagChain:
	var new_chain = self.copy_chain()
	new_chain.append_source(type, source)
	return new_chain

func get_all_tags()->Array:
	var out_list = []
	for id in _source_order:
		out_list.append_array(_source_tags[id])
	return out_list

func has_tag(tag):
	for source in _source_tags.values():
		for h_tag in source:
			if tag == h_tag:
				return true
	return false

## Returns true if any String value in check_for appears in the tag list.
static func tags_include_any_in_array(check_for:Array, tags:Array)->bool:
	for check in check_for:
		if tags.has(check):
			return true
	return false
