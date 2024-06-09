extends PanelContainer

#references to objects
@onready var titleLabel = %Title
@onready var descriptionLabel = %Description
@onready var costLabel = %Cost
@onready var outline_color = %OutlineColor

#dictionary to convert letter type to corresponding number
@onready var typeToNum = {"a": 1, "i": 2, "n": 3};

#instantiating important vars
var cost;
var type; # 1 = active, 2 = idle, 3 = neutral
var title;
var description;
var bought;
var upgradeID;
var main;

#determines if the object is being hovered or not
var hovered = false;

signal getBits();
signal removeBits(amount);

# Called when the node enters the scene tree for the first time.
func _ready():
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	#updates the color of the object every frame
	updatecolor();

#basically a contructor of this upgrade object
func setParams(typeI, costI, titleI, descriptionI, upgradeIDI):
	bought = false;
	type = typeI;
	cost = costI;
	title = titleI;
	description = descriptionI;
	upgradeID = upgradeIDI;
	
	updateDescription();

#updates the description of the object using given information
func updateDescription():
	descriptionLabel.set_text(description);
	
	#if cost is 0 that means this upgrade object isnt being used yet
	if(cost == 0):
		costLabel.set_text("");
	else:
		costLabel.set_text("Cost: " + str(cost));
	titleLabel.set_text(title);

#updates the color of the object
func updatecolor():
	var alpha = modulate.a;
	
	#if alpha is less than 1 that means it is in the process of appearing
	if(alpha < 1):
		
		#if the upgrade was bought while it was appearing, skip the animation
		if(bought):
			modulate.a = 1;
			return;

	#type of 0 means the upgrade object isnt in use
	if(type == 0):
		outline_color.border_color = Color.DARK_GRAY.darkened(0.5);
		return;
	
	#assigns a color based on type
	# 1 = active, 2 = idle, 3 = neutral
	var choosenColor;
	if(type == 1):
		choosenColor = Color.RED;
	elif(type == 2):
		choosenColor = Color.DEEP_SKY_BLUE;
	elif(type == 3):
		choosenColor = Color.DARK_ORANGE;
	
	outline_color.border_color = choosenColor
	
	#if the upgrade isnt bought, it will be slightly darker
	if(!bought):
		outline_color.border_color = outline_color.border_color.darkened(0.3);
		
	outline_color.border_width = 3;
	
	#determines whether youre allowed to buy the upgrade branch
	var allowed = true;
	if(hovered):
		if(!canBuy() && !bought):
			allowed = false;
			mouse_default_cursor_shape = Control.CURSOR_FORBIDDEN;
		else:
			mouse_default_cursor_shape = Control.CURSOR_ARROW;
	
	#if the upgrade is hovered over, isnt bought, and allowed to be purchased
	#then it slightly lights up and border size increases
	if(hovered && !bought && allowed):
		outline_color.border_color = outline_color.border_color.lightened(0.3);
		outline_color.border_width = 4;
	
	#sets the overall color of the object to its border color
	modulate = outline_color.border_color;
	
	#if the upgrade is bought, the upgrade is slightly brighter
	if(bought):
		modulate = modulate.lightened(0.3);
	
	#updates the alpha value if its less than 1
	#and overrides the current alpha to the lesser one
	if(alpha < 1):
		modulate.a = alpha;
		updatealpha();
		return;
	

#called when an upgrade is clicked on
func _on_gui_input(event):
	if(event.is_action_pressed("click")):
		#if upgrade isnt used, do nothing
		if(type == 0):
			return;
		
		#if not purchasable, do nothing
		if(!canBuy()):
			return;
		
		#if the user has enough bits and hasnt purchased the upgrade before, buy the upgrade
		if(main.getBits() >= cost && !main.getUpgrades().has(upgradeID)):
			main.removeBits(cost);
			bought = true;
			main.camera_shake(0.3);
			main.addUpgrade(upgradeID);
			
			costLabel.set_text("-= BOUGHT =-");

#sets the hovered var to true when the upgrade is hovered over
func _on_mouse_entered():
	main = get_tree().root.get_child(0);
	hovered = true;

#when the mouse stops hovering, update the var
func _on_mouse_exited():
	hovered = false;

#starts the animation for when an upgrade first appears (fades in)
func appear():
	updatecolor();
	modulate.a = 0.0;
	main = get_tree().root.get_child(0);

#updates the alpha value by slightly increasing it over time
func updatealpha():
	if(cost == 0):
		return;
	
	if(modulate.a < 1.0):
		modulate.a += 0.025;
		modulate.a = clamp(modulate.a, 0.0, 1.0);

#determines if the user is allowed to buy from this branch of upgrades
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
