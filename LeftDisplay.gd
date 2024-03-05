extends Control

@onready var level_display = %"Level Display"
@onready var tree = %FolderTree



# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func set_level(level):
	level_display.text = "Level " + str(level);

func tree_create(level):
	tree.create(level);
