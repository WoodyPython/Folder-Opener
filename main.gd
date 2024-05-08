extends Node

var level;
var bits;
var shake = 0.0;
var upgradeList = [];
var levelTime = 0;

@export var RANDOM_SHAKE_STRENGTH = 30.0;
@export var SHAKE_DECAY = 5.0;

@onready var left_display = %"Left Display";
@onready var right_display  = %"Right Display";
@onready var camera = %Camera;

@onready var rand = RandomNumberGenerator.new();


# Called when the node enters the scene tree for the first time.
func _ready():
	start();

func start():
	level = 1;
	bits = 9999;
	left_display.tree_create(level);
	right_display.display_bits(bits);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_level_display();
	
	shake = lerp(shake, 0.0, SHAKE_DECAY * delta);
	camera.offset = get_random_offset();
	
	levelTime += delta;

#checks for a key press, if esc then quits the game
func _input(event):
	if(event.is_action_pressed("esc")):
		get_tree().quit();
	if(event.is_action_pressed("newTree")):
		nextLevel(0);

func update_level_display():
	left_display.set_level(level);
	right_display.display_bits(bits);

func nextLevel(hasDisk):
	var totalGain = level;
	
	if(upgradeList.has("n3")):
		totalGain += 1;
		
	if(upgradeList.has("n9")):
		var multi = 1/levelTime + 1;
		totalGain *= multi;
		totalGain = round(totalGain);
	
	if(hasDisk == 1):
		totalGain *= 5;
	grantBits(totalGain);
	
	var levelGain = 1;
	if(upgradeList.has("n7")):
		levelGain += 1;
	level += levelGain;
	update_level_display();
	left_display.tree_create(level);
	
	camera_shake(2);
	levelTime = 0;


func _on_left_display_next_level(disk):
	call_deferred("nextLevel", disk);

#resets the shake value, causing screen to shake again
func camera_shake(percent):
	shake = RANDOM_SHAKE_STRENGTH * percent;

#gets the random offset based on current shake	
func get_random_offset():
	return Vector2(rand.randf_range(-shake, shake), rand.randf_range(-shake, shake));


func _on_left_display_screen_shake(percent):
	camera_shake(percent);

func getBits():
	return bits;

func removeBits(remove):
	bits -= remove;
	
func addUpgrade(id):
	upgradeList.append(id);

func getUpgrades():
	return upgradeList;

func grantBits(gain):
	if(upgradeList.has("n6")):
		gain *= 2;
	bits += gain;
	
