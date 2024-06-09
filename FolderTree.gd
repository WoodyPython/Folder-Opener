extends Tree

#creating important vars

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

#object reference
@onready var left_display = $"../../.."

#creating files
@onready var nameFile = "res://Folder_Names.txt";
@onready var nameFileRare = "res://Folder_Names_Rare.txt";

#getting main
@onready var main = get_tree().root.get_child(0);

var folderNames;
var folderNamesRare;

#setting up signals
signal updateDirectory(selected, objectives);
signal showObjectives(objectives);
signal diskClaimed();
signal screenShake(strength);
signal getCompletedObj();

# Called when the node enters the scene tree for the first time.
func _ready():
	#on start, setting up the noise function
	noise.noise_type = FastNoiseLite.NoiseType.TYPE_PERLIN;
	noise.seed = rng.randi_range(-9999, 9999);
	noise.fractal_octaves = 4;
	noise.frequency = 1.0 / 10.0;
	
	#this fixes a weird resizing bug
	z_as_relative = false;
	z_as_relative = true;

#returns the given file as an array of strings
func loadFile(file):
	var newFile = FileAccess.open(file, FileAccess.READ);
	var names = newFile.get_as_text();
	var nameList = names.split("\n");
	nameList.remove_at(nameList.size()-1);
	return nameList;
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#checking whether the user has the auto folder opening upgrade
	if(main.getUpgrades().has("i3") && left_display.togglesList.has("auto-open")):
		
		#only activates every interval
		secondCount += delta;
		if(secondCount >= autoOpenInterval):
			secondCount = 0;

			if(main.getUpgrades().has("i6")):
				autoOpenInterval *= 0.9;
			
			#checking which folders are elligible to be opened
			var validFolders = [];
			for folder in foldersList:
				if(folder.get_parent() == null && folder.collapsed):
					validFolders.append(folder);
					continue;
				if(folder.collapsed && !folder.get_parent().collapsed):
					validFolders.append(folder);
			
			#if valid folders isnt empty, pick a random one within it to open
			if(!validFolders.is_empty()):
				var choosenFolder = validFolders.pick_random();
				choosenFolder.collapsed = false;
	
	#checking if the user has auto objective claim upgrade
	if(main.getUpgrades().has("i5")):
		
		#checking if an objective is valid and claims one every interval
		for obj in objectives:
			if(!obj.get_parent().collapsed && !left_display.completedObjectives.has(obj)):
				secondCount2 += delta;
				var threshold = 10.0;
				if(main.getUpgrades().has("i7")):
					threshold = 3.0;
				if(secondCount2 <= threshold):
					break;
					
				#once the interval happens, complete objective and update display for it
				secondCount2 = 0.0;
				left_display.completedObjectives.append(obj);
				left_display.update_objectives(objectives);
				obj.set_icon(0, preload("res://Textures/Found.png"));
				
				#claiming an objective grants bits if the user has this upgrade
				if(main.getUpgrades().has("n4")):
					main.grantBits(3);

#creates a folder hierarchy, which scales based off the 'level'
func create(level):
	
	#resetting previous tree
	self.clear();
	autoOpenInterval = 5;
	secondCount = 0;
	totalFolders = 0;
	foldersList = [];
	diskFiles = [];
	chainFiles = [];
	var scaling = 1.5;
	
	#calculating scaling
	if(main.getUpgrades().has("n2")):
		scaling += 0.15;
		
	level = ceil(log(level+1) / log(scaling));
	maxLevel = level;
	
	#creating the base root
	var root = self.create_item();
	root.set_text(0, "Computer");
	totalFiles = [];
	
	#calculating how many objectives there will be
	var objCount = ceil(log(maxLevel+1) / log(3));
	if(rng.randi_range(0, 2) == 0):
		objCount-=1;
	elif(rng.randi_range(0, 2) == 0):
		objCount+=1;
	objCount = max(objCount, 1);
	
	objNames = [];
	
	#loading the txt files for the different folder names to use
	folderNames = loadFile(nameFile);
	folderNamesRare = loadFile(nameFileRare);
	
	#picking exclusive names for the objectives
	#these names won't ever repeat/recycle in the tree
	for i in objCount:
		var index = randi() % folderNames.size();
		objNames.append(folderNames[index]);
		folderNames.remove_at(index);
	
	#creating the tree
	appendTree(level, root, "flat");
	root.set_tooltip_text(0, " ");
	root.set_collapsed_recursive(true);

	self.scroll_to_item(root);
	
	root.set_icon(0, preload("res://Textures/ComputerIcon.png"));
	
	#creating the objectives 
	objectives = [];
	for i in objCount:
		createObjective();
	emit_signal("showObjectives", objectives);
	root.select(0);
	
	#creating special folder types based on bought upgrades
	if(main.getUpgrades().has("a5")):
		if(rng.randi_range(1,20) == 1):
			createDisk();
	
	if(main.getUpgrades().has("a4")):
		for i in objCount:
			createChain();
	
	if(main.getUpgrades().has("i2")):
		root.collapsed = false;

#recursive function, adds a child to the root based on level and type
func appendTree(level, root, type):
	
	#recursive stop checks
	if(totalFolders >= maxLevel * 5):
		return;
		
	if(level <= 0):
		return;
		
	#calculating the max amount of folders that can be added to the root
	var noiseValue = abs(noise.get_noise_1d(level));
	var maxRange = round(noiseValue * 4 * (maxLevel - level + 2));
	
	#manipulating range and amount based on type
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
	
	#if the amount is more than 0, then the root becomes a folder, otherwise stays as a file
	if(repeatNum > 0):
		totalFolders += 1;
		totalFiles.erase(root);
	
	#creating children (files) of the root
	var children = [];
	for i in repeatNum:
		var child = self.create_item(root);
		children.append(child);
	
	#randomly goes through each child and determines if they should become a folder too
	for i in repeatNum:
		var child = children.pick_random();
		children.erase(child);
		
		child.set_tooltip_text(0, " ");
		child.get_parent().set_icon(0, preload("res://Textures/FolderIcon.png"));
		
		#setting random file texture
		if(rng.randi_range(1,2) == 1):
			child.set_icon(0, preload("res://Textures/FileIcon.png"));
		else:
			child.set_icon(0, preload("res://Textures/EmptyFile.png"));
			
		totalFiles.append(child);
		foldersList.append(child.get_parent());
		
		#calculating chance of file becoming folder
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
		
		#if the list is empty, start recycling names (causes repeated names within the tree)
		if(folderNames.size() == 0):
			folderNames = loadFile(nameFile);
			for currentName in objNames:
				folderNames.remove_at(folderNames.find(currentName));
		if(folderNamesRare.size() == 0):
			folderNamesRare = loadFile(nameFileRare);

		var usedfile = folderNames;
		
		#chance for a guaranteed folder
		if(rng.randi_range(1, 20) == 1 || level == maxLevel):
			#rare names are guaranteed to be folders
			usedfile = folderNamesRare;
			moveOnChance = 1;
		
		#picks a name from the choosen names file
		var index = randi() % usedfile.size();
		child.set_text(0, usedfile[index]);
		usedfile.remove_at(index);
		
		#if the file can become a folder, theres a chance to save the current scaling
		if moveOnChance >= 0:
			var saveLevel = false;
			if(type == "jab"):
				if(rng.randi_range(1, 3) <= 2):
					saveLevel = true;
			if(rng.randi_range(1, 10) == 1):
				saveLevel = true;
			
			#decreases the level each depth, reducing scaling and cap for higher depth files/folders
			var newLevel = level - 1;
			if(saveLevel):
				newLevel = level;
				if(type == "jab"):
					newLevel += 1;
			
			#recursively creates the file a folder 
			appendTree(newLevel, child, newType);

#picks a random file type, which determines how its children (files) generate
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

#creates an objective
func createObjective():
	#if there are no available files, then the objective cant spawn
	if(totalFiles.is_empty()):
		return;
		
	#picks a random file and makes it an objective
	var file = totalFiles.pick_random();
	totalFiles.erase(file);
	file.set_text(0, objNames.pop_front());
	
	#having certain upgrades make the objective easier to find
	if(main.getUpgrades().has("n5")):
		file.set_icon(0, preload("res://Textures/ObjectiveFile.png"));
		
	if(main.getUpgrades().has("a3")):
		if(file.get_parent().get_parent() != null):
			file.get_parent().set_icon(0, preload("res://Textures/ObjectiveFolder.png"));
	
	#appends the chosen file to the objective list
	objectives.append(file);
	
#when a file is clicked, checks for if that file was special
func _on_cell_selected():
	if(diskFiles.has(get_selected())):
		emit_signal("diskClaimed");
		return;
		
	if(chainFiles.has(get_selected())):
		createFolderChain();
		get_selected().set_icon(0, preload("res://Textures/EmptyFile.png"));
		chainFiles.erase(get_selected());
	
	#updates the file directory when any file or folder is clicked
	emit_signal("updateDirectory", get_selected(), objectives);

#when a file is double clicked, check if the user has that kind of upgrade
#if yes, an additional random folder gets opened up within clicked folder
func _on_item_activated():
	if(main.getUpgrades().has("a2")):
		get_selected().collapsed = !get_selected().collapsed;
		if(!get_selected().collapsed):
			var folders = [];
			
			#checks for valid folders to open
			for folder in get_selected().get_children():
				if(folder.get_child_count() != 0 && folder.collapsed):
					folders.append(folder);
			
			#if the valid list isnt empty, pick a random folder and open it
			if(!folders.is_empty()):
				var openFolder = folders.pick_random();
				openFolder.collapsed = false;

#creates a disk file
func createDisk():
	if(totalFiles.is_empty()):
		return;
	
	#picks a random file and makes it a disk type
	var file = totalFiles.pick_random();
	totalFiles.erase(file);
	
	file.set_icon(0, preload("res://Textures/DiskFile.png"));
	diskFiles.append(file);
	
#creates a chain file
func createChain():
	if(totalFiles.is_empty()):
		return;
	
	#picks a random file and makes it a chain type
	var file = totalFiles.pick_random();
	totalFiles.erase(file);
	
	file.set_icon(0, preload("res://Textures/ChainFile.png"));
	chainFiles.append(file);

#creates a chain of folders from a chain file
func createFolderChain():
	emit_signal("screenShake", 1);
	
	#if all objectives were found, there is no path to build
	if(objectives.is_empty()):
		return;
	
	#gets which objectives were found so far
	var validObjectives = [];
	emit_signal("getCompletedObj");
	
	#checks each objective, and and if it wasnt claimed them it is valid
	for obj in objectives:
		if(!completedObj.has(obj)):
			if(obj.get_parent().get_icon(0) != preload("res://Textures/ChainFolder.png")):
				validObjectives.append(obj);
	
	#picks a random objective from the valid list if it isnt empty
	if(validObjectives.is_empty()):
		return;
		
	var origin = validObjectives.pick_random();
	chainFolder(origin);

#recursively builds a chain of folders / files that are colored blue
func chainFolder(child):
	#once it reaches the base root (computer), stop recursion
	if(child.get_parent().get_parent() == null):
		return;
	
	#sets the folder to blue and continues going up
	child.get_parent().set_icon(0, preload("res://Textures/ChainFolder.png"));
	chainFolder(child.get_parent());

#sets the completed objectives to the given list
func _on_left_display_return_completed(completed):
	completedObj = completed;
