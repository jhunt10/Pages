@tool
class_name EntryGroupContainer
extends BackPatchContainer

@export var title_label:Label
@export var entries_container:BoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	pass

func add_entry(entry:PageDetailsEntryContainer):
	entries_container.add_child(entry)
	pass
