extends VBoxContainer

@onready var list = %List
@onready var button = %LevelCompleteBtn

var objectives;

# Called when the node enters the scene tree for the first time.
func _ready():
	button.disabled = true;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update(completed, total):
	list.clear();
	var i = 0;
	button.disabled = true;
	button.icon = preload("res://Textures/NotFound.png");
	
	for obj in total:
		list.add_item(obj.get_text(0), null, false);
		if(completed.has(obj)):
			list.set_item_disabled(i, true);
			list.set_item_icon(i, preload("res://Textures/Found.png"));
		else:
			list.set_item_icon(i, preload("res://Textures/NotFound.png"));
		i += 1;
	list.set_fixed_icon_size(Vector2i(20, 20));
	
	if(completed.size() == total.size()):
		button.disabled = false;
		button.icon = preload("res://Textures/Found.png");
