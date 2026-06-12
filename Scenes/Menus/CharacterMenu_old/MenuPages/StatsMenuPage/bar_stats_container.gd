@tool
class_name BarStatsDisplayContainer
extends BackPatchContainer

@export var health_bar_container:BarStatEntryContainer
@export var divider:ColorRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint(): return
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	if Engine.is_editor_hint(): return
	pass

func set_actor(actor:BaseActor):
	for child in inner_container.get_children():
		if child == health_bar_container or child == divider:
			continue
		child.queue_free()
	divider.visible = false
	var bar_count = 1
	for bar_stat_name in actor.stats.list_bar_stat_names():
		var color = StatHelper.StatBarColors.get(bar_stat_name, Color.WHITE)
		var max_val = actor.stats.get_bar_stat_max(bar_stat_name)
		var regen = actor.stats.get_bar_stat_regen_per_round(bar_stat_name)
		if bar_stat_name == "Health":
			health_bar_container.set_stat_vals(color, bar_stat_name, max_val, regen)
			continue
		elif bar_count == 1:
			divider.visible = true
		else:
			var new_div = divider.duplicate()
			new_div.visible = true
			inner_container.add_child(new_div)
		var new_bar = health_bar_container.duplicate()
		new_bar.set_stat_vals(color, bar_stat_name, max_val, regen)
		inner_container.add_child(new_bar)
		bar_count += 1
