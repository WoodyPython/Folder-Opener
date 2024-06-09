extends VBoxContainer

#object references
@onready var list = %List
@onready var button = %LevelCompleteBtn
@onready var left_display = $"../../.."
@onready var notif_box = %NotifBox

#instantiating important vars
@onready var main = get_tree().root.get_child(0);
var notifObject;
var objectives;
var ogLvl;

#creating signals
signal nextLevel();

# Called when the node enters the scene tree for the first time.
func _ready():
	button.disabled = true;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	#clears the level up notification if a new level has started
	if(main.level != ogLvl && notifObject != null):
		clearNotif();

#updates the objective list display based on completed objectives and all objectives
func update(completed, total):
	
	#resets the list
	list.clear();
	var i = 0;
	button.disabled = true;
	button.icon = preload("res://Textures/NotFound.png");
	
	#goes through each objective and adds it to the objective list
	for obj in total:
		list.add_item(obj.get_text(0), null, false);
		list.set_item_tooltip_enabled(i, false);
		
		#if the objective is completed, it has a new texture
		if(completed.has(obj)):
			list.set_item_disabled(i, true);
			list.set_item_icon(i, preload("res://Textures/Found.png"));
		else:
			list.set_item_icon(i, preload("res://Textures/NotFound.png"));
			
		i += 1;
		
	list.set_fixed_icon_size(Vector2i(20, 20));
	
	#if all the objectives were found, then the button to level up is now available
	if(completed.size() == total.size()):
		
		#checks if the user has access to auto level-up
		if(main.getUpgrades().has("i4") && left_display.togglesList.has("auto-complete")):
			emit_signal("nextLevel");
			return;
			
		button.disabled = false;
		button.icon = preload("res://Textures/Found.png");
		ogLvl = main.level;
		setNotification();

#creates a notification effect next to the level up button
func setNotification():
	notifObject = preload("res://notification.tscn").instantiate();
	main.add_child(notifObject);
	notifObject.add_parent(notif_box);

#removes the notification effect
func clearNotif():
	main.remove_child(notifObject);
	notifObject = null;

