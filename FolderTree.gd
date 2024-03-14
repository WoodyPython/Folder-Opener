extends Tree

var noise = FastNoiseLite.new();
var rng = RandomNumberGenerator.new();
var maxLevel;
var totalFolders;

@onready var nameFile = "res://Folder_Names.txt";
@onready var nameFileRare = "res://Folder_Names_Rare.txt";
var folderNames;
var folderNamesRare;


signal updateDirectory(selected);

# Called when the node enters the scene tree for the first time.
func _ready():
	noise.noise_type = FastNoiseLite.NoiseType.TYPE_PERLIN;
	noise.seed = rng.randi_range(-9999, 9999);
	noise.fractal_octaves = 4;
	noise.frequency = 1.0 / 10.0;
	
	folderNames = loadFile(nameFile);
	folderNamesRare = loadFile(nameFileRare);
	
	
func loadFile(file):
	var newFile = FileAccess.open(file, FileAccess.READ);
	var names = newFile.get_as_text();
	var nameList = names.split("\n");
	nameList.remove_at(nameList.size()-1)
	return nameList;
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass;

func create(level):
	self.clear();
	totalFolders = 0;
	
	maxLevel = level;
		
	var root = self.create_item();
	root.set_text(0, "Computer");
	
	appendTree(level, root, "flat");
	root.set_collapsed_recursive(true);
	root.select(0);
	self.scroll_to_item(root);
	

func appendTree(level, root, type):
	if(totalFolders >= maxLevel * 5):
		return;
	if(level <= 0):
		return;
		
	#noise.seed = rng.randi_range(-9999, 9999);
	var noiseValue = abs(noise.get_noise_1d(level));
	#print(noiseValue);
	var maxRange = round(noiseValue * 5 * (maxLevel - level + 2));
	
	if(type == "flat"):
		maxRange *= 1.3;
	elif(type == "jab"):
		maxRange *= 0.7;
	
	var repeatNum = rng.randi_range(1, maxRange);
	if(type == "flat"):
		repeatNum += 2;
	elif(type == "staircase"):
		repeatNum = 1;
	#print(str(maxRange) + " " + str(repeatNum) + " " + type);
	#repeatNum = clamp(repeatNum, 1, maxLevel/4+1);
	
	for i in repeatNum:
		var child = self.create_item(root);
		var icon = preload("res://icon.svg");

		child.set_icon(0, icon);
		totalFolders += 1;
		var moveOnChance = rng.randf_range(-1 * maxLevel, level);
		if(level + 2 >= maxLevel):
			moveOnChance += 0.8;
		if(type == "flat"):
			moveOnChance -= 0.2;
		elif(type == "jab"):
			moveOnChance += 0.4;
		elif(type == "staircase"):
			moveOnChance += 0.5;
		var newType = getNewType(type);
		
		
		if(folderNames.size() == 0):
			folderNames = loadFile(nameFile);
		if(folderNamesRare.size() == 0):
			folderNamesRare = loadFile(nameFileRare);
		
		var usedfile = folderNames;
		if(rng.randi_range(1, 20) == 1):
			usedfile = folderNamesRare;
			moveOnChance = 1;

		
		var index = randi() % usedfile.size();
		child.set_text(0, usedfile[index]);
		usedfile.remove_at(index);
		
		
		if moveOnChance >= 0:
			var saveLevel = false;
			if(type == "jab"):
				if(rng.randi_range(1, 3) <= 2):
					saveLevel = true;
			if(rng.randi_range(1, 10) == 1):
				saveLevel = true;
			
			var newLevel = level - 1;
			if(saveLevel):
				newLevel = level;
				if(type == "jab"):
					newLevel += 1;
				
			appendTree(newLevel, child, newType);

func getNewType(type):
	if(type == "staircase"):
		return type;
	
	if(rng.randi_range(1, 3) <= 2):
		return type;
	
	var typeList = ["jab", "flat"];
	typeList.erase(type);
	
	var newType = typeList.pick_random();
	if(rng.randi_range(1, 10) == 1):
		newType = ["staircase"].pick_random();
	
	return newType;

func _on_cell_selected():
	emit_signal("updateDirectory", get_selected());
