extends PanelContainer

var rng = RandomNumberGenerator.new();

@onready var file_data_names = %FileDataNames
@onready var file_data_types = %FileDataTypes
@onready var file_data = %FileData

@onready var contentNamesFile = "res://File_Content_Names.txt";
@onready var contentTypesFile = "res://File_Content_Types.txt";

var contentNames;
var contentTypes;

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
	
	file_data_names.add_item("(Default)", preload("res://Textures/Gear.png"), false);
	file_data_types.add_item("REG_SZ", null, false);
	file_data.add_item("(value not set)", null, false);
	disableTooltip(1);
	if(selected.get_icon(0) != preload("res://Textures/FileIcon.png") || isObjective):
		return;
	
	contentNames = loadFile(contentNamesFile);
	contentTypes = loadFile(contentTypesFile);
	
	var amount = rng.randi_range(1, 5);
	var nameList = [];
	for i in amount:
		var index = randi() % contentNames.size();
		nameList.append(contentNames[index]);
		contentNames.remove_at(index);
	nameList.sort();
	
	var typeList = [];
	amount = rng.randi_range(1, 2);
	for i in amount:
		var index = randi() % contentTypes.size();
		typeList.append(contentTypes[index]);
		contentTypes.remove_at(index);
		
	for pickedName in nameList:
		file_data_names.add_item(pickedName, preload("res://Textures/Gear.png"), false);
		file_data_types.add_item(typeList.pick_random(), null, false);
		file_data.add_item("(value not set)", null, false);
	
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
