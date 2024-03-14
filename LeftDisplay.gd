extends Control

@onready var level_display = %"Level Display"
@onready var tree = %FolderTree
@onready var objective_list = %ObjectiveList
@onready var directory = %"Directory Display"

var directoryName;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_objectives();


func set_level(level):
	level_display.text = "Level " + str(level);

func tree_create(level):
	tree.create(level);

func update_objectives():
	objective_list.update();


func _on_folder_tree_update_directory(selected):
	directoryName = "";

	getDirectory(selected);
	directory.set_text(directoryName);
	
func getDirectory(selected):
	if(selected == null):
		return "";
	
	getDirectory(selected.get_parent());
	if(selected.get_parent() != null):
		directoryName += "\\";
	directoryName += str(selected.get_text(0));
