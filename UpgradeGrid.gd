extends GridContainer

var upgradeList;
@onready var upgradeObjectScene = preload("res://upgrade_object.tscn");


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in 10:
		var upgradeObject = upgradeObjectScene.instantiate();
		add_child(upgradeObject);
		upgradeObject.setParams(1, i+1, "First Upgrade", "This is a description of all time.", i+1);


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass;
