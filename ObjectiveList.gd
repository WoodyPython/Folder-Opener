extends VBoxContainer

@onready var list = %List
@onready var button = %LevelCompleteBtn
@onready var left_display = $"../../.."
@onready var notif_box = %NotifBox

@onready var main = get_tree().root.get_child(0);
var notifObject;
var objectives;
var ogLvl;

signal nextLevel();
# Called when the node enters the scene tree for the first time.
func _ready():
	button.disabled = true;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(main.level != ogLvl && notifObject != null):
		clearNotif();

func update(completed, total):
	list.clear();
	var i = 0;
	button.disabled = true;
	button.icon = preload("res://Textures/NotFound.png");
	
	for obj in total:
		list.add_item(obj.get_text(0), null, false);
		list.set_item_tooltip_enabled(i, false);
		if(completed.has(obj)):
			list.set_item_disabled(i, true);
			list.set_item_icon(i, preload("res://Textures/Found.png"));
		else:
			list.set_item_icon(i, preload("res://Textures/NotFound.png"));
		i += 1;
	list.set_fixed_icon_size(Vector2i(20, 20));
	
	if(completed.size() == total.size()):
		if(main.getUpgrades().has("i4") && left_display.togglesList.has("auto-complete")):
			emit_signal("nextLevel");
			return;
		button.disabled = false;
		button.icon = preload("res://Textures/Found.png");
		ogLvl = main.level;
		setNotification();

func setNotification():
	notifObject = preload("res://notification.tscn").instantiate();
	main.add_child(notifObject);
	notifObject.add_parent(notif_box);
	
func clearNotif():
	main.remove_child(notifObject);
	notifObject = null;

