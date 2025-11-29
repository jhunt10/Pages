@tool
class_name EntryGroupContainer
extends BackPatchContainer

@export var title_label:Label
@export var count_label:Label
@export var entries_container:BoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	pass

func add_entry(entry:BaseObjectDetailsEntryContainer):
	entries_container.add_child(entry)
	count_label.text = "     (" + str(entries_container.get_child_count()) + ")"
	pass
