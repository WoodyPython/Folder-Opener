extends Node

var level;

@onready var left_display = %"Left Display"



# Called when the node enters the scene tree for the first time.
func _ready():
	start();

func start():
	
	level = 1;
	left_display.tree_create(level);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_level_display();
	#pass

#checks for a key press, if esc then quits the game
func _input(event):
	if(event.is_action_pressed("esc")):
		get_tree().quit();
	if(event.is_action_pressed("newTree")):
		nextLevel();

func update_level_display():
	left_display.set_level(level);

func nextLevel():
	level += 1;
	update_level_display();
	left_display.tree_create(level);


func _on_left_display_next_level():
	call_deferred("nextLevel");
