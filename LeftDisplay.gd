extends Control

@onready var level_display = %"Level Display"
@onready var tree = %FolderTree
@onready var objective_list = %ObjectiveList
@onready var directory = %"Directory Display"
@onready var completeParticles = %LvlCompleteParticles
@onready var objectiveParticles = %ObjectiveParticles

@onready var main = get_tree().root.get_child(0);
var completedObjectives;
var directoryName;


var rng = RandomNumberGenerator.new();

signal nextLevel();
signal screenShake(percent);

# Called when the node enters the scene tree for the first time.
func _ready():
	pass;


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
			if(main.getUpgrades().has("n4")):
				main.grantBits(1);
				objectiveParticles.position = get_viewport().get_mouse_position();
				objectiveParticles.position.y -= 100;
				objectiveParticles.amount = rng.randi_range(4, 7);
				objectiveParticles.emitting = true;
				objectiveParticles.restart();
			
			selected.set_icon(0, preload("res://Textures/Found.png"));
			
			emit_signal("screenShake", 0.5);
			
			completedObjectives.append(selected);
			
		update_objectives(objectives);
			
	
func getDirectory(selected):
	if(selected == null):
		return "";
	
	getDirectory(selected.get_parent());
	if(selected.get_parent() != null):
		directoryName += "\\";
	directoryName += str(selected.get_text(0));


func _on_folder_tree_show_objectives(objectives):
	update_objectives(objectives);



func _on_level_complete_btn_pressed():
	completeParticles.emitting = true;
	completeParticles.restart();
	emit_signal("nextLevel");
