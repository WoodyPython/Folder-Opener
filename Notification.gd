extends PanelContainer

#size of the notification
@onready var displaySize = 10;

#determines wether the size is increasing or decreasing
@onready var increase = true;

#the set "parent" of the object
var parent;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(increase):
		#using lerp to smoothly change size
		displaySize = lerp(float(displaySize), float(displaySize + delta*5), 5);
		
		#the bound for when to switch directions
		if(displaySize >= 25):
			increase = false;
	else:
		displaySize = lerp(float(displaySize), float(displaySize - delta*4), 5);
		if(displaySize <= 15):
			increase = true;
	
	displaySize = clamp(displaySize, 15, 25);
	self.size = Vector2(displaySize, displaySize);
	
	goToParent();

#makes this object go to the parent
func goToParent():
	position.x = parent.global_position.x + parent.size.x/3.0;
	position.y = parent.global_position.y + parent.size.y/3.0;

#sets the given parent object to the parent variable
func add_parent(newParent):
	parent = newParent;
