class_name SourceTagChain

enum SourceTypes {Actor, Action, Missile, Effect, }

# Array of source ids in order of parent to child
var _source_order:Array = []
# Dictionary of source_id to tags for that source
var _source_tags:Dictionary = {}
var source_actor:BaseActor

func _init() -> void:
	pass

func force_add_tag(tags):
	if tags is String:
		tags = [tags]
	if not _source_tags.has("LooseList"):
		_source_tags['LooseList'] = []
	_source_tags['LooseList'].append_array(tags)
	return self

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
	var out_list = _source_tags.get("LooseList", [])
	for id in _source_order:
		out_list.append_array(_source_tags[id])
	return out_list

func has_tag(tag):
	for source in _source_tags.values():
		for h_tag in source:
			if tag == h_tag:
				return true
	return false

func get_source_actor()->BaseActor:
	return source_actor

## Returns true if any String value in check_for appears in the tag list.
static func tags_include_any_in_array(check_for:Array, tags:Array)->bool:
	for check in check_for:
		if tags.has(check):
			return true
	return false

## Returns true if all String values in check_for appears in the tag list.
static func tags_include_all_in_array(check_for:Array, tags:Array)->bool:
	var is_valid = true
	for check in check_for:
		if not tags.has(check):
			is_valid = false
			break
	return is_valid

static func filters_accept_tags(tag_filter:Dictionary, tags:Array)->bool:
	if tag_filter.get("RequireAllTags", []).size() > 0:
		var require_tags = tag_filter.get('RequireAllTags')
		if not tags_include_all_in_array(require_tags, tags):
			return false
	if tag_filter.get("RequireAnyTags", []).size() > 0:
		var require_tags = tag_filter.get('RequireAnyTags')
		if not tags_include_any_in_array(require_tags, tags):
			return false
	if tag_filter.get("ExcludeAllTags", []).size() > 0:
		var exclude_tags = tag_filter.get('ExcludeAllTags')
		if tags_include_all_in_array(exclude_tags, tags):
			return false
	if tag_filter.get("ExcludeAnyTags", []).size() > 0:
		var exclude_tags = tag_filter.get('ExcludeAnyTags')
		if tags_include_any_in_array(exclude_tags, tags):
			return false
	return true
