extends Control

@onready var level_display = %"Level Display"
@onready var tree = %FolderTree
@onready var objective_list = %ObjectiveList
@onready var directory = %"Directory Display"

var completedObjectives;
var directoryName;

signal nextLevel();

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass;


func set_level(level):
	level_display.text = "Level " + str(level);

func tree_create(level):
	completedObjectives = [];
	tree.create(level);


func update_objectives(objectives):
	objective_list.update(completedObjectives, objectives);


func _on_folder_tree_update_directory(selected, objectives):
	directoryName = "";

	getDirectory(selected);
	directory.set_text(directoryName);
	
	if(objectives.has(selected)):
		if(!completedObjectives.has(selected)):
			completedObjectives.append(selected);
		update_objectives(objectives);
		if(completedObjectives.size() == objectives.size()):
			emit_signal("nextLevel");
			
	
func getDirectory(selected):
	if(selected == null):
		return "";
	
	getDirectory(selected.get_parent());
	if(selected.get_parent() != null):
		directoryName += "\\";
	directoryName += str(selected.get_text(0));


func _on_folder_tree_show_objectives(objectives):
	update_objectives(objectives);
