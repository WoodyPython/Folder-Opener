extends Node

#creates base tier vars
var level;
var bits;
var shake = 0.0;
var upgradeList = [];
var levelTime = 0;

#makes default screen shake values
#the code for screen shake was gotten from this video: https://www.youtube.com/watch?v=RVtcnkuNUIk
@export var RANDOM_SHAKE_STRENGTH = 30.0;
@export var SHAKE_DECAY = 5.0;

#references to objects
@onready var left_display = %"Left Display";
@onready var right_display = %"Right Display";
@onready var camera = %Camera;
@onready var outerContainer = %HBoxContainer
var rainbowIndex = 0;

@onready var notificationScene = preload("res://notification.tscn");

@onready var rand = RandomNumberGenerator.new();

var notifObject;

#called when the node enters the scene tree for the first time.
func _ready():
	start();

#creates default stats and updates respective displays
func start():
	level = 1;
	bits = 0;
	left_display.tree_create(level);
	right_display.display_bits(bits);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	#updates various screens/labels every frame
	update_level_display();
	update_toggles();
	#update_rainbow();
	
	#shakes the screen but constantly decreases shake value to 0 every frame
	shake = lerp(shake, 0.0, SHAKE_DECAY * delta);
	
	#offsets the camera to create a shake effects
	camera.offset = get_random_offset();
	
	#keep track of how long the level takes to complete
	levelTime += delta;

#checks for a key press
func _input(event):
	if(event.is_action_pressed("esc")):
		get_tree().quit();
	
	#dev hotkey
	#if(event.is_action_pressed("newTree")):
	#	nextLevel(0);

#updates the respective screens for the level and bits display
func update_level_display():
	left_display.set_level(level);
	right_display.display_bits(bits);

#starts the next level, and checks if the previous one claimed a Disk File
func nextLevel(hasDisk):
	var totalGain = level;
	
	#calculating how much the user gets on level completion
	if(upgradeList.has("n3")):
		totalGain += 1;
		
	if(upgradeList.has("n9")):
		var multi = 1/levelTime + 1;
		totalGain *= multi;
		totalGain = round(totalGain);
	
	if(hasDisk == 1):
		totalGain *= 2;
		
	grantBits(totalGain);
	
	#calculates by how much to increase the level count
	var levelGain = 1;
	if(upgradeList.has("n7")):
		levelGain += 1;
	level += levelGain;
	
	#updates the respective screens on new level
	update_level_display();
	left_display.tree_create(level);
	
	#clears the saved file data from the run
	clearFileData();
	
	camera_shake(2);
	levelTime = 0;

#starts new level
#call_deferred because otherwise the screen doesnt load intime and it crashes
# it basically waits for the screen to load before executing the function call
func _on_left_display_next_level(disk):
	call_deferred("nextLevel", disk);

#resets the shake value to the given percentage, causing screen to shake again
func camera_shake(percent):
	if(!right_display.toggleList.has("screenshake")):
		return;
		
	shake = RANDOM_SHAKE_STRENGTH * percent;

#returns a random offset based on current shake	
func get_random_offset():
	return Vector2(rand.randf_range(-shake, shake), rand.randf_range(-shake, shake));

#causes screen shake based on percent
func _on_left_display_screen_shake(percent):
	camera_shake(percent);

#returns current bits
func getBits():
	return bits;

#subtracts bits by the given amount
func removeBits(remove):
	bits -= remove;

#adds an upgrade id to the bought upgrade list
func addUpgrade(id):
	upgradeList.append(id);

#returns the list of upgrades
func getUpgrades():
	return upgradeList;

#increments bits by the given amount
func grantBits(gain):
	if(upgradeList.has("n6")):
		gain *= 2;
	bits += gain;
	
#gets the file contents of the selected file and whether its an objective
func _on_left_display_get_contents(selected, isObjective):
	right_display.getContents(selected, isObjective);

#clears the saved file data from the run
func clearFileData():
	right_display.clearFileData();

#emits particles at the given location
func emitObjParticles(pos):
	left_display.emitParticles(pos);

#updates the toggle menu given the upgrade list
func update_toggles():
	right_display.updateToggles(upgradeList);

#updates toggle preferences in a different screen given the toggle list
func updateTogglesLeft(toggleList):
	left_display.updateToggles(toggleList);

#experimental function, changes overall color of the viewable screen
func update_rainbow():
	rainbowIndex += 1;
	if(rainbowIndex > 255):
		rainbowIndex = 0;
	
	outerContainer.modulate = Color.from_hsv(rainbowIndex/255.0, 1, 1, 1);
