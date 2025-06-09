## Que Equipment holds all the parameters for the Actor's Pages, but PageHolder manages the pages
class_name BaseQueEquipment
extends BaseEquipmentItem

var _cached_slots_data:Array[Dictionary] = []

func get_equipment_slot_type()->String:
	return "Book"

func _init(key:String, def_load_path:String, def:Dictionary, id:String='', data:Dictionary={}) -> void:
	super(key, def_load_path, def, id, data)

func get_max_page_count()->int:
	var tagged_slots = get_load_val("PageTagSlots", {})
	var count = 0
	for slot_count in tagged_slots.values():
		count += slot_count
	return count

func get_pages_per_round()->int:
	return get_load_val("PagesPerRound", 0)

func get_base_passive_page_limit()->int:
	return get_load_val("BasePassiveCount", 0)
func get_base_action_page_limit()->int:
	return get_load_val("BaseActionCount", 0)

func get_passive_stat_mods()->Array:
	var ppr_mod = BaseStatMod.new(_id, "PPR", self.get_display_name(), BaseStatMod.ModTypes.Set, get_pages_per_round())
	var mod_list = [ppr_mod]
	mod_list.append_array(super())
	return mod_list

func get_page_slot_data()->Array[Dictionary]:
	if _cached_slots_data.size() == 0:
		_cached_slots_data = [
			{
				"Key":"TitlePage",
				"DisplayName":"Title Page",
				"Count": 1,
				"FilterData":{
					"RequiredTags":"Title"
				}
			},
			{
				"Key":"BasePassives",
				"DisplayName":"Passives",
				"Count": get_load_val("BasePassiveCount", 0),
				"FilterData":{
					"RequiredTags":["Passive"]
				}
			},
			{
				"Key":"BaseActions",
				"DisplayName":"Actions",
				"Count": get_load_val("BaseActionCount", 0),
				"FilterData":{
					"RequiredTags":["Action"]
				}
			}
		]
		for extra_slot in get_load_val("ItemSlotsData", []):
			_cached_slots_data.append(extra_slot)
	return _cached_slots_data
	
