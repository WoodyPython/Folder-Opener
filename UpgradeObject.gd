extends PanelContainer

@onready var titleLabel = %Title
@onready var descriptionLabel = %Description
@onready var costLabel = %Cost
@onready var outline_color = %OutlineColor

var cost;
var type; # 1 = active, 2 = idle, 3 = neutral
var title;
var description;
var bought;
var upgradeID;

var hovered = false;

signal getBits();
signal removeBits(amount);

# Called when the node enters the scene tree for the first time.
func _ready():
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	updatecolor();

func setParams(type, cost, title, description, upgradeID):
	bought = false;
	self.type = type;
	
	self.cost = cost;
	self.title = title;
	self.description = description;
	self.upgradeID = upgradeID;
	
	updateDescription();
	
func updateDescription():
	descriptionLabel.set_text(description);
	costLabel.set_text("Cost: " + str(cost));
	titleLabel.set_text(title);

func updatecolor():
	if(bought):
		outline_color.border_color = Color.CHARTREUSE;
	else:
		if(type == 1):
			outline_color.border_color = Color.DARK_RED;
		elif(type == 2):
			outline_color.border_color = Color.DEEP_SKY_BLUE;
		elif(type == 3):
			outline_color.border_color = Color.TOMATO;
	
	if(hovered):
		outline_color.border_color = outline_color.border_color.lightened(0.3);
	


func _on_gui_input(event):
	if(event.is_action_pressed("click")):
		var main = get_tree().root.get_child(0);
		if(main.getBits() >= cost && !main.upgradeList.has(upgradeID)):
			main.removeBits(cost);
			bought = true;
			main.camera_shake(0.5);
			main.addUpgrade(upgradeID);
			
			costLabel.set_text("-= BOUGHT =-");

func _on_mouse_entered():
	hovered = true;

func _on_mouse_exited():
	hovered = false;
