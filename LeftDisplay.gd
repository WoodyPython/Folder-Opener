extends Control

#creating a lot of references to objects
@onready var level_display = %"Level Display"
@onready var tree = %FolderTree
@onready var objective_list = %ObjectiveList
@onready var directory = %"Directory Display"
@onready var completeParticles = %LvlCompleteParticles
@onready var objectiveParticles = %ObjectiveParticles

@onready var main = get_tree().root.get_child(0);
var completedObjectives;
var directoryName;
@onready var togglesList = [];

var rng = RandomNumberGenerator.new();

#creating signals
signal nextLevel(disk);
signal screenShake(percent);
signal returnCompleted(completed);
signal getContents(selected, isObjective);

# Called when the node enters the scene tree for the first time.
func _ready():
	pass;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass;

#sets the level display to the given level
func set_level(level):
	level_display.text = "Level " + str(level);

#calls the folder tree to create a folder hierarchy based on level
func tree_create(level):
	completedObjectives = [];
	tree.create(level);

#updates the objective list given the current and completed objectives
func update_objectives(objectives):
	objective_list.update(completedObjectives, objectives);
					
#updates the directory given the clicked file and the objectives
func _on_folder_tree_update_directory(selected, objectives):
	directoryName = "";
	
	emit_signal("getContents", selected, objectives.has(selected));
	
	getDirectory(selected);
	directory.set_text(directoryName);
	
	#if the clicked file is an objective and its valid then collect it
	if(objectives.has(selected)):
		if(!completedObjectives.has(selected)):
			
			#if the user has this upgrade, collecting an objective grants bits
			if(main.getUpgrades().has("n4")):
				main.grantBits(3);
				var pos = get_viewport().get_mouse_position();
				emitParticles(pos);
			
			#marks the objective as found
			selected.set_icon(0, preload("res://Textures/Found.png"));
			
			emit_signal("screenShake", 0.5);
			
			completedObjectives.append(selected);
		
		#update the objective list 
		update_objectives(objectives);
			
#emits particles at the given location
func emitParticles(pos):
	objectiveParticles.position = pos;
	objectiveParticles.amount = rng.randi_range(4, 7);
	objectiveParticles.emitting = true;
	objectiveParticles.restart();

#recursively gets the directory of the given folder/file
func getDirectory(selected):
	if(selected == null):
		return "";
	
	getDirectory(selected.get_parent());
	if(selected.get_parent() != null):
		directoryName += "\\";
		
	directoryName += str(selected.get_text(0));

#redirects this call to update the objective list given the objectives
func _on_folder_tree_show_objectives(objectives):
	update_objectives(objectives);

#starts the next level
func _on_level_complete_btn_pressed():
	startNextLevel(0);

#start the next level, given if the level up happened from a Disk File or not
func startNextLevel(disk):
	completeParticles.emitting = true;
	completeParticles.restart();
	emit_signal("nextLevel", disk);

#starts the next level
func _on_objective_list_next_level():
	startNextLevel(0);

#starts the next level, but with the disk claimed
func _on_folder_tree_disk_claimed():
	startNextLevel(1);

#calls the screen shake function based on strength
func _on_folder_tree_screen_shake(strength):
	emit_signal("screenShake", strength);

#returns the currently completed objectives
func _on_folder_tree_get_completed_obj():
	emit_signal("returnCompleted", completedObjectives);

#updates the toggle list to the given list
func updateToggles(toggleList):
	togglesList = toggleList;
