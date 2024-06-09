extends PanelContainer

var rng = RandomNumberGenerator.new();

#references to the important children
@onready var file_data_names = %FileDataNames
@onready var file_data_types = %FileDataTypes
@onready var file_data = %FileData

#getting the files of the names
@onready var contentNamesFile = "res://File_Content_Names.txt";
@onready var contentTypesFile = "res://File_Content_Types.txt";

#reference to main
@onready var main = get_tree().root.get_child(0);

#instantiating some important vars
var contentNames;
var contentTypes;
var current;

#stores an array of: [nameList, typeList, dataList, bitList, collectedList] for each clicked file object
var savedFileData = {};

# Called when the node enters the scene tree for the first time.
func _ready():
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass;

#returns the given txt file as an array of strings
func loadFile(file):
	var newFile = FileAccess.open(file, FileAccess.READ);
	var names = newFile.get_as_text();
	var nameList = names.split("\n");
	nameList.remove_at(nameList.size()-1);
	return nameList;

#sets the contents of the three lists when selecting a file.
#"selected" is the clicked on file, and "isObjective" determines if it was an objective
func getContents(selected, isObjective):
	
	#clears contents and sets some default vars
	clearContents();
	file_data_names.set_fixed_icon_size(Vector2i(20, 20));
	current = selected;
	
	#appends a default value, which exists for any folder/file
	file_data_names.add_item("(Default)", preload("res://Textures/DefaultContent.png"), false);
	file_data_types.add_item("REG_SZ", null, false);
	file_data.add_item("(value not set)", null, false);
	
	#disables the hover text
	disableTooltip(1);
	
	#if the clicked file isnt a content file then it does nothing, or if its an objective
	if(selected.get_icon(0) != preload("res://Textures/FileIcon.png") || isObjective):
		return;
	
	#setting more default values on vars
	var amount = rng.randi_range(1, 5);
	var nameList = [];
	var typeList = [];
	var dataList = [];
	var bitList = [];
	var collectedList = [];
	
	#loads the txt files into an array of strings
	contentNames = loadFile(contentNamesFile);
	contentTypes = loadFile(contentTypesFile);
	
	#checks if the file was clicked on prior, and sets the data to what it was before
	#this is to prevent overriding existing data and generating new data ontop of it
	if(savedFileData.has(selected)):
		nameList = savedFileData.get(selected)[0];
		typeList = savedFileData.get(selected)[1];
		dataList = savedFileData.get(selected)[2];
		bitList = savedFileData.get(selected)[3];
		collectedList = savedFileData.get(selected)[4];
	else:
		
		#chooses random names to display
		for i in amount:
			var index = randi() % contentNames.size();
			nameList.append(contentNames[index]);
			contentNames.remove_at(index);
		nameList.sort();
		
		#generates random bit data which when clicked on grants bits.
		# 10% chance per name
		for i in nameList:
			if(rng.randi_range(1,10) == 1 && !bitList.has(i)):
				bitList.append(i);
		
		#sets the amount and which content types to pick from
		#max of 2 different types
		amount = rng.randi_range(1, 2);
		var validTypes = [];
		for i in amount:
			var index = randi() % contentTypes.size();
			validTypes.append(contentTypes[index]);
			contentTypes.remove_at(index);
		
		#appends random types from valid types
		for i in nameList:
			typeList.append(validTypes.pick_random());
		
		#appends random data based on the choosen types
		dataList = [];
		for type in typeList:
			dataList.append(getData(type));
	
	#adds the respective content to visual display from the already generated lists of data
	var i = 0;
	for pickedName in nameList:
		var icon = preload("res://Textures/NormalContent.png");
		if(bitList.has(pickedName)):
			icon = preload("res://Textures/BitContentType.png");
		if(collectedList.has(pickedName)):
			icon = preload("res://Textures/Gear.png");
			
		file_data_names.add_item(pickedName, icon, false);
		file_data_types.add_item(typeList[i], null, false);
		file_data.add_item(dataList[i], null, false);
		i += 1;
	
	#saves the data so that when clicked off and back on, the same data appears
	savedFileData[selected] = [nameList, typeList, dataList, bitList, collectedList];
	
	#disables hover text
	disableTooltip(nameList.size()+1);

#clears what is being visually displayed
func clearContents():
	file_data_names.clear();
	file_data_types.clear();
	file_data.clear();

#disables hover text for the given number of rows
func disableTooltip(count):
	for i in count:
		file_data_names.set_item_tooltip_enabled(i, false);
		file_data_types.set_item_tooltip_enabled(i, false);
		file_data.set_item_tooltip_enabled(i, false);

#removes all data that was saved for the files
func clearData():
	savedFileData = {};

#returns randomly generated data depending on the given type
func getData(type):
	#predetermined list of characters to use
	var binList = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, "a", "b", "c", "d", "e", "f"];
	
	#checks for the given types and returns appropriate data
	if(type == "REG_NONE"):
		return "(zero-length binary value)";
		
	if(type == "REG_DWORD" || type == "REG_MULTI_SZ"):
		var word = "0x00";
		for i in 6:
			word += str(binList.pick_random());
			
		if(type == "REG_MULTI_SZ"):
			if(rng.randi_range(0, 1) == 0):
				word += " 00 00 00 00 00 00 00 00";
			else:
				word += " ";
				for i in 5:
					word += str(binList.pick_random()) + str(binList.pick_random()) + " ";
				word += "00 00 00";
				
		if(rng.randi_range(0, 1) == 0):
			word += " (" + str(rng.randi_range(0, 2)) + ")";
		else:
			word += " (" + str(rng.randi_range(40000, 4294967295)) + ")";
			
		return word;
		
	if(type == "REG_BINARY"):
		var word = "";
		
		if(rng.randi_range(0, 1) == 0):
			word = "00 00 00 00 00 00 00 00";
		else:
			for i in 5:
				word += str(binList.pick_random()) + str(binList.pick_random()) + " ";
			word += "00 00 00";
			
		return word;
		
	if(type == "REG_SZ"):
		if(rng.randi_range(1, 6) == 1):
			return "(None)";
		if(rng.randi_range(1, 3) == 1):
			return str(rng.randi_range(0, 2));
		if(rng.randi_range(1, 3) == 1):
			return str(rng.randi_range(10, 100));
		if(rng.randi_range(1, 2) == 1):
			return str(rng.randi_range(100, 255)) + " " + str(rng.randi_range(100, 255)) + " " + str(rng.randi_range(100, 255));
		
		return "0 0 0";
		
	if(type == "REG_EXPAND_SZ"):
		if(rng.randi_range(1, 4) == 1):
			return "(None)";
		if(rng.randi_range(1, 3) == 1):
			return str(rng.randi_range(100, 1000));
		if(rng.randi_range(1, 2) == 1):
			return "false";
			
		return "true";
		
	if(type == "REG_QWORD"):
		var word = "1";
		for i in 63:
			word += str(rng.randi_range(0, 1));
			
		return word;
	
	#if none of the types matched to the given one, then returns this
	return "(value not set)";

#when a content item is clicked on, checks for if it was a bit type
#if it was, grants the user bits and does some special effects
func _on_file_data_names_item_clicked(index, at_position, mouse_button_index):
	
	#checks if it was a bit type
	if(file_data_names.get_item_icon(index) == preload("res://Textures/BitContentType.png")):
		
		#removes the possibility of clicking on the same bit type multiple times
		#and adds a value to the collected bits list within saved data to remember this
		savedFileData.get(current)[3].erase(file_data_names.get_item_text(index));
		savedFileData.get(current)[4].append(file_data_names.get_item_text(index));
		
		#effects
		main.grantBits(1);
		main.camera_shake(0.4);
		var pos = get_viewport().get_mouse_position();
		main.emitObjParticles(pos);
		
		#updates the content display
		getContents(current, false);
		
