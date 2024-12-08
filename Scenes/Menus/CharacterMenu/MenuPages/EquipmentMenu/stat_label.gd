class_name StatLabelContainer
extends HBoxContainer

@export var stat_name:String
@export var name_label:Label
@export var value_label:Label
@export var regen_label:Label

func set_stat_values(actor:BaseActor, stat:String=''):
	if stat == '':
		stat = stat_name
	if stat != stat_name:
		stat_name = stat
	var stat_val = actor.stats.get_stat(stat_name, 0)
	value_label.text = str(stat_val)
	if stat.begins_with("Max:"):
		var bar_stat_name = stat.trim_prefix("Max:")
		stat_val = actor.stats.get_bar_stat_max(bar_stat_name)
		if stat_val == 0:
			self.hide()
			return
		else:
			self.show()
		value_label.text = str(stat_val)
		var regen_round = actor.stats.get_bar_stat_regen_per_round(bar_stat_name)
		var regen_turn = actor.stats.get_bar_stat_regen_per_turn(bar_stat_name)
		if regen_label:
			if regen_round:
				regen_label.text = " + %s PR" % [regen_round]
				regen_label.show()
			elif regen_turn:
				regen_label.text = " + %s PT" % [regen_turn]
				regen_label.show()
			else:
				regen_label.hide()
	
