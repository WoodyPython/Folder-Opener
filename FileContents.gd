extends PanelContainer

var rng = RandomNumberGenerator.new();

@onready var file_data_names = %FileDataNames
@onready var file_data_types = %FileDataTypes
@onready var file_data = %FileData

@onready var contentNamesFile = "res://File_Content_Names.txt";
@onready var contentTypesFile = "res://File_Content_Types.txt";
@onready var main = get_tree().root.get_child(0);

var contentNames;
var contentTypes;
var savedFileData = {};
var current;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass;
	
func loadFile(file):
	var newFile = FileAccess.open(file, FileAccess.READ);
	var names = newFile.get_as_text();
	var nameList = names.split("\n");
	nameList.remove_at(nameList.size()-1);
	return nameList;

func getContents(selected, isObjective):
	clearContents();
	file_data_names.set_fixed_icon_size(Vector2i(20, 20));
	current = selected;
	
	file_data_names.add_item("(Default)", preload("res://Textures/DefaultContent.png"), false);
	file_data_types.add_item("REG_SZ", null, false);
	file_data.add_item("(value not set)", null, false);
	disableTooltip(1);
	if(selected.get_icon(0) != preload("res://Textures/FileIcon.png") || isObjective):
		return;
		
	var amount = rng.randi_range(1, 5);
	var nameList = [];
	var typeList = [];
	var dataList = [];
	var bitList = [];
	var collectedList = [];
	
	contentNames = loadFile(contentNamesFile);
	contentTypes = loadFile(contentTypesFile);
	
	if(savedFileData.has(selected)):
		nameList = savedFileData.get(selected)[0];
		typeList = savedFileData.get(selected)[1];
		dataList = savedFileData.get(selected)[2];
		bitList = savedFileData.get(selected)[3];
		collectedList = savedFileData.get(selected)[4];
	else:
		for i in amount:
			var index = randi() % contentNames.size();
			nameList.append(contentNames[index]);
			contentNames.remove_at(index);
		nameList.sort();
		
		for i in nameList:
			if(rng.randi_range(1,10) == 1 && !bitList.has(i)):
				bitList.append(i);
		
		amount = rng.randi_range(1, 2);
		var validTypes = [];
		for i in amount:
			var index = randi() % contentTypes.size();
			validTypes.append(contentTypes[index]);
			contentTypes.remove_at(index);
		for i in nameList:
			typeList.append(validTypes.pick_random());
		
		dataList = [];
		for type in typeList:
			dataList.append(getData(type));
			
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
	
	savedFileData[selected] = [nameList, typeList, dataList, bitList, collectedList];
	
	disableTooltip(nameList.size()+1);
	#print(nameList);

func clearContents():
	file_data_names.clear();
	file_data_types.clear();
	file_data.clear();

func disableTooltip(count):
	for i in count:
		file_data_names.set_item_tooltip_enabled(i, false);
		file_data_types.set_item_tooltip_enabled(i, false);
		file_data.set_item_tooltip_enabled(i, false);

func clearData():
	savedFileData = {};

func getData(type):
	var binList = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, "a", "b", "c", "d", "e", "f"];
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
			word += " ("+str(rng.randi_range(0, 2))+")";
		else:
			word += " ("+str(rng.randi_range(40000, 4294967295))+")";
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
		
	return "(value not set)";


func _on_file_data_names_item_clicked(index, at_position, mouse_button_index):
	if(file_data_names.get_item_icon(index) == preload("res://Textures/BitContentType.png")):
		savedFileData.get(current)[3].erase(file_data_names.get_item_text(index));
		savedFileData.get(current)[4].append(file_data_names.get_item_text(index));
		
		main.grantBits(1);
		main.camera_shake(0.4);
		var pos = get_viewport().get_mouse_position();
		main.emitObjParticles(pos);
				
		getContents(current, false);
		
