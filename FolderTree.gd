extends Tree


# Called when the node enters the scene tree for the first time.
func _ready():
	create(1);


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func create(level):
	
	var root = self.create_item()
	root.set_text(0, "root")
	
	var child1 = self.create_item(root)
	child1.set_text(0, "child1")
	
	var child2 = self.create_item(root)
	child2.set_text(0, "child2")
	
	var subchild1 = self.create_item(child1)
	subchild1.set_text(0, "Subchild1")
	
	var subchild2 = self.create_item(child2)
	subchild2.set_text(0, "Subchild2")
