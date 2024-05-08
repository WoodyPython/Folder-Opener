extends Tree

var noise = FastNoiseLite.new();
var rng = RandomNumberGenerator.new();
var maxLevel;
var totalFolders;
var totalFiles;

var secondCount = 0;
var secondCount2 = 0;
var autoOpenInterval = 5;

var objectives;
var objNames = [];
var foldersList = [];
var diskFiles = [];
var chainFiles = [];
var completedObj = [];

@onready var left_display = $"../../.."

@onready var nameFile = "res://Folder_Names.txt";
@onready var nameFileRare = "res://Folder_Names_Rare.txt";
@onready var main = get_tree().root.get_child(0);

var folderNames;
var folderNamesRare;

signal updateDirectory(selected, objectives);
signal showObjectives(objectives);
signal diskClaimed();
signal screenShake(strength);
signal getCompletedObj();

# Called when the node enters the scene tree for the first time.
func _ready():
	noise.noise_type = FastNoiseLite.NoiseType.TYPE_PERLIN;
	noise.seed = rng.randi_range(-9999, 9999);
	noise.fractal_octaves = 4;
	noise.frequency = 1.0 / 10.0;
	
	
func loadFile(file):
	var newFile = FileAccess.open(file, FileAccess.READ);
	var names = newFile.get_as_text();
	var nameList = names.split("\n");
	nameList.remove_at(nameList.size()-1);
	return nameList;
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(main.getUpgrades().has("i3")):
		secondCount += delta;
		if(secondCount >= autoOpenInterval):
			secondCount = 0;
			if(main.getUpgrades().has("i6")):
				autoOpenInterval *= 0.9;
			var validFolders = [];
			for folder in foldersList:
				if(folder.get_parent() == null && folder.collapsed):
					validFolders.append(folder);
					continue;
				if(folder.collapsed && !folder.get_parent().collapsed):
					validFolders.append(folder);
			
			if(!validFolders.is_empty()):
				var choosenFolder = validFolders.pick_random();
				choosenFolder.collapsed = false;
	
	if(main.getUpgrades().has("i5")):
		for obj in objectives:
			if(!obj.get_parent().collapsed && !left_display.completedObjectives.has(obj)):
				secondCount2 += delta;
				var threshold = 10.0;
				if(main.getUpgrades().has("i7")):
					threshold = 3.0;
				if(secondCount2 <= threshold):
					break;
				secondCount2 = 0.0;
				left_display.completedObjectives.append(obj);
				left_display.update_objectives(objectives);

func create(level):
	self.clear();
	autoOpenInterval = 5;
	secondCount = 0;
	totalFolders = 0;
	foldersList = [];
	diskFiles = [];
	chainFiles = [];
	var scaling = 1.5;
	
	if(main.getUpgrades().has("n2")):
		scaling += 0.15;
	level = ceil(log(level+1) / log(scaling));
	maxLevel = level;

	var root = self.create_item();
	root.set_text(0, "Computer");
	
	totalFiles = [];
	var objCount = ceil(log(maxLevel+1) / log(3));
	if(rng.randi_range(0, 2) == 0):
		objCount-=1;
	elif(rng.randi_range(0, 2) == 0):
		objCount+=1;
	objCount = max(objCount, 1);
	
	objNames = [];
	
	folderNames = loadFile(nameFile);
	folderNamesRare = loadFile(nameFileRare);
	
	for i in objCount:
		var index = randi() % folderNames.size();
		objNames.append(folderNames[index]);
		folderNames.remove_at(index);
	
	appendTree(level, root, "flat");
	root.set_collapsed_recursive(true);

	self.scroll_to_item(root);
	
	root.set_icon(0, preload("res://Textures/ComputerIcon.png"));
	
	objectives = [];
	for i in objCount:
		createObjective();
	emit_signal("showObjectives", objectives);
	root.select(0);
	
	if(main.getUpgrades().has("a5")):
		if(rng.randi_range(1,4) == 1):
			createDisk();
	
	if(main.getUpgrades().has("a4")):
		for i in objCount:
			createChain();
	
	if(main.getUpgrades().has("i2")):
		root.collapsed = false;

func appendTree(level, root, type):
	if(totalFolders >= maxLevel * 5):
		return;
	if(level <= 0):
		return;
		
	#noise.seed = rng.randi_range(-9999, 9999);
	var noiseValue = abs(noise.get_noise_1d(level));
	var maxRange = round(noiseValue * 4 * (maxLevel - level + 2));
	
	if(type == "flat"):
		maxRange *= 1.3;
	elif(type == "jab"):
		maxRange *= 0.6;
	
	var repeatNum = rng.randi_range(1, maxRange);
	if(type == "flat"):
		repeatNum += 2;
	elif(type == "staircase"):
		repeatNum = 1;
	
	if(level + 1 >= maxLevel):
		repeatNum += 1;
	
	#repeatNum = clamp(repeatNum, 1, maxLevel/4+1);
	if(repeatNum > 0):
		totalFolders += 1;
		totalFiles.erase(root);
		
	for i in repeatNum:
		var child = self.create_item(root);
		child.get_parent().set_icon(0, preload("res://Textures/FolderIcon.png"));
		if(rng.randi_range(1,2) == 1):
			child.set_icon(0, preload("res://Textures/FileIcon.png"));
		else:
			child.set_icon(0, preload("res://Textures/EmptyFile.png"));
		totalFiles.append(child);
		foldersList.append(child.get_parent());
		
		var moveOnChance = rng.randf_range(-1 * maxLevel, level);
		if(level + 2 >= maxLevel):
			moveOnChance += 0.8;
		if(type == "flat"):
			moveOnChance -= 0.2;
		elif(type == "jab"):
			moveOnChance += 0.6;
		elif(type == "staircase"):
			moveOnChance += 0.7;
		var newType = getNewType(type);
		
		
		if(folderNames.size() == 0):
			folderNames = loadFile(nameFile);
			for currentName in objNames:
				folderNames.remove_at(folderNames.find(currentName));
		if(folderNamesRare.size() == 0):
			folderNamesRare = loadFile(nameFileRare);

		var usedfile = folderNames;
		if(rng.randi_range(1, 20) == 1 || level == maxLevel):
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

func createObjective():
	if(totalFiles.is_empty()):
		return;
	var file = totalFiles.pick_random();
	totalFiles.erase(file);
	file.set_text(0, objNames.pop_front());
	if(main.getUpgrades().has("n5")):
		file.set_icon(0, preload("res://Textures/ObjectiveFile.png"));
	if(main.getUpgrades().has("a3")):
		if(file.get_parent().get_parent() != null):
			file.get_parent().set_icon(0, preload("res://Textures/ObjectiveFolder.png"));
	objectives.append(file);
	

func _on_cell_selected():
	if(diskFiles.has(get_selected())):
		emit_signal("diskClaimed");
		return;
	if(chainFiles.has(get_selected())):
		createFolderChain();
		get_selected().set_icon(0, preload("res://Textures/EmptyFile.png"));
		chainFiles.erase(get_selected());
	emit_signal("updateDirectory", get_selected(), objectives);


func _on_item_activated():
	if(main.getUpgrades().has("a2")):
		get_selected().collapsed = !get_selected().collapsed;
		if(!get_selected().collapsed):
			var folders = [];
			for folder in get_selected().get_children():
				if(folder.get_child_count() != 0 && folder.collapsed):
					folders.append(folder);
			if(!folders.is_empty()):
				var openFolder = folders.pick_random();
				openFolder.collapsed = false;

func createDisk():
	if(totalFiles.is_empty()):
		return;
	var file = totalFiles.pick_random();
	totalFiles.erase(file);
	
	file.set_icon(0, preload("res://Textures/DiskFile.png"));
	diskFiles.append(file);
	
func createChain():
	if(totalFiles.is_empty()):
		return;
	var file = totalFiles.pick_random();
	totalFiles.erase(file);
	
	file.set_icon(0, preload("res://Textures/ChainFile.png"));
	chainFiles.append(file);

func createFolderChain():
	emit_signal("screenShake", 1);
	if(objectives.is_empty()):
		return;
	var validObjectives = [];
	emit_signal("getCompletedObj");

	for obj in objectives:
		if(!completedObj.has(obj)):
			if(obj.get_parent().get_icon(0) != preload("res://Textures/ChainFolder.png")):
				validObjectives.append(obj);
	
	if(validObjectives.is_empty()):
		return;
	var origin = validObjectives.pick_random();
	chainFolder(origin);
	
func chainFolder(child):
	if(child.get_parent().get_parent() == null):
		return;
	child.get_parent().set_icon(0, preload("res://Textures/ChainFolder.png"));
	chainFolder(child.get_parent());


func _on_left_display_return_completed(completed):
	completedObj = completed;
