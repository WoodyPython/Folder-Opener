extends PanelContainer

@onready var titleLabel = %Title
@onready var descriptionLabel = %Description
@onready var costLabel = %Cost

var cost;
var type;
var title;
var description;
var bought;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func setParams(type, cost, title, description):
	bought = false;
	self.type = type;
	self.cost = cost;
	self.title = title;
	self.description = description;
	
	updateDescription();
	
func updateDescription():
	descriptionLabel.set_text(description);
	costLabel.set_text("Cost: " + str(cost));
	titleLabel.set_text(title);
