extends Tree


# Called when the node enters the scene tree for the first time.
func _ready():
	#create(1);
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func create(level):
	
	var root = self.create_item()
	root.set_text(0, "base root");
	appendTree(level, root);

func appendTree(level, root):
	if(level <= 0):
		return;
	var rng = RandomNumberGenerator.new();
	var repeatNum = rng.randi_range(1, level);
	print(repeatNum);
	for i in repeatNum:
		var child = self.create_item(root);
		child.set_text(0, "child "+str(level)+"."+str(i));
		appendTree(level-1, child);
	
