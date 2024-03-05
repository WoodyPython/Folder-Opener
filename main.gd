extends Node

var level;

@onready var left_display = %"Left Display"



# Called when the node enters the scene tree for the first time.
func _ready():
	start();

func start():
	
	level = 5;
	#left_display.tree_create(level);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_level_display(level);
	pass

#checks for a key press, if esc then quits the game
func _input(event):
	if(event.is_action_pressed("esc")):
		get_tree().quit();

func update_level_display(level):
	left_display.set_level(level);
