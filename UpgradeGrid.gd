extends GridContainer

var upgradeList;
@onready var upgradeObject = preload("res://upgrade_object.tscn").instantiate();


# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(upgradeObject);
	upgradeObject.setParams("basic", 10, "First Upgrade", "This is a description of all time.");


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
