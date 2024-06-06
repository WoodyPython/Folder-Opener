extends PanelContainer

@onready var titleLabel = %Title
@onready var descriptionLabel = %Description
@onready var costLabel = %Cost
@onready var outline_color = %OutlineColor

@onready var typeToNum = {"a": 1, "i": 2, "n": 3};

var cost;
var type; # 1 = active, 2 = idle, 3 = neutral
var title;
var description;
var bought;
var upgradeID;
var main;

var hovered = false;

signal getBits();
signal removeBits(amount);

# Called when the node enters the scene tree for the first time.
func _ready():
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	updatecolor();

func setParams(typeI, costI, titleI, descriptionI, upgradeIDI):
	bought = false;
	type = typeI;
	cost = costI;
	title = titleI;
	description = descriptionI;
	upgradeID = upgradeIDI;
	
	updateDescription();
	
func updateDescription():
	descriptionLabel.set_text(description);
	if(cost == 0):
		costLabel.set_text("");
	else:
		costLabel.set_text("Cost: " + str(cost));
	titleLabel.set_text(title);

func updatecolor():
	var alpha = modulate.a;
	if(alpha < 1):
		if(bought):
			modulate.a = 1;
			return;

		
	if(type == 0):
		outline_color.border_color = Color.DARK_GRAY.darkened(0.5);
		return;
	
	var choosenColor;
	if(type == 1):
		choosenColor = Color.RED;
	elif(type == 2):
		choosenColor = Color.DEEP_SKY_BLUE;
	elif(type == 3):
		choosenColor = Color.DARK_ORANGE;
	
	outline_color.border_color = choosenColor
	
	if(!bought):
		outline_color.border_color = outline_color.border_color.darkened(0.3);
		
	outline_color.border_width = 3;
	
	var allowed = true;
	if(hovered):
		if(!canBuy() && !bought):
			allowed = false;
			mouse_default_cursor_shape = Control.CURSOR_FORBIDDEN;
		else:
			mouse_default_cursor_shape = Control.CURSOR_ARROW;
	
	if(hovered && !bought && allowed):
		outline_color.border_color = outline_color.border_color.lightened(0.3);
		outline_color.border_width = 4;
	
	modulate = outline_color.border_color;
	if(bought):
		modulate = modulate.lightened(0.3);
	
	if(alpha < 1):
		modulate.a = alpha;
		updatealpha();
		return;
	


func _on_gui_input(event):
	if(event.is_action_pressed("click")):
		if(type == 0):
			return;
		
		if(!canBuy()):
			return;
		
		if(main.getBits() >= cost && !main.getUpgrades().has(upgradeID)):
			main.removeBits(cost);
			bought = true;
			main.camera_shake(0.3);
			main.addUpgrade(upgradeID);
			
			costLabel.set_text("-= BOUGHT =-");

func _on_mouse_entered():
	main = get_tree().root.get_child(0);
	hovered = true;

func _on_mouse_exited():
	hovered = false;

func appear():
	updatecolor();
	modulate.a = 0.0;
	main = get_tree().root.get_child(0);
	
func updatealpha():
	if(cost == 0):
		return;
	
	if(modulate.a < 1.0):
		modulate.a += 0.025;
		modulate.a = clamp(modulate.a, 0.0, 1.0);

func canBuy():
	var specificUpgCount = {1: 0, 2: 0, 3: 0};
	for upgrade in main.getUpgrades():
		specificUpgCount[typeToNum[upgrade[0]]] += 1;
	var limit = 0;
	if(main.getUpgrades().has("n8")):
		limit += 3;
	if(type == 1 && specificUpgCount[1] == limit && specificUpgCount[2] > limit || type == 2 && specificUpgCount[2] == limit && specificUpgCount[1] > limit):
		return false;
	
	return true;
