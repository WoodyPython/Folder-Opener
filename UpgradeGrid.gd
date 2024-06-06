extends GridContainer

@onready var upgradeObjectScene = preload("res://upgrade_object.tscn");

#type, cost, title, description, prereq amount
@onready var upgrades = {"upg1.1" : [1, 1, "Active Path", "By buying this upgrade you unlock all other upgrades within this branch. You will not be able to buy upgrades from the Idle Branch!", 0], 
				"upg2.1" : [2, 1, "Idle Path", "By buying this upgrade you unlock all other upgrades within this branch. You will not be able to buy upgrades from the Active Branch!", 0],
				"upg3.1" : [3, 1, "Neutral Path", "By buying this upgrade you unlock all other upgrades within this branch.", 0],
				"upg1.2" : [1, 5, "Manual Labor", "Allows you to double-click to open a folder. When double clicking a folder, open a random folder inside of it. ", 1],
				"upg1.3" : [1, 10, "Improved Vision", "Folders will now be colored blue if they contain an objective. Depth of 1. Does not including the Computer.", 1], 
				"upg1.4" : [1, 20, "Chained Combo", "Some files will now become Chained Files, which when clicked on will reveal the direction to one of the objectives. The number of these files equals the number of Objective Files.", 3],
				"upg1.5" : [1, 20, "Just One", "There is a rare chance to spawn a single Disk File. Clicking on one automatically completes the level and rewards 5x the Bits.", 3],
				"upg2.2" : [2, 2, "Less Labor", "The Computer is automatically opened when starting a new level.", 1],
				"upg2.3" : [2, 5, "Automation Age", "Every 5 seconds a random folder is opened up. Also unlock a toggle to turn this off.", 1], 
				"upg2.4" : [2, 15, "Less Clicks", "Finding all objectives now automatically levels up, without needing to manually do so. Also unlock a toggle to turn this off.", 2],
				"upg2.5" : [2, 25, "Simple Collection", "If an Objective is on screen, automatically collect it after 10 seconds.", 3],
				"upg2.6" : [2, 30, "Accelerated Pace", "The speed of opening folders increases with every folder opened (10% faster / folder).", 3],
				"upg2.7" : [2, 50, "Quick Collection", "The time to automatically collect an objective is reduced to 3 seconds.", 5],
				"upg3.2" : [3, 10, "Reduced Scales", "Level scaling is slightly reduced.", 1],
				"upg3.3" : [3, 5, "More Gains", "Gain an extra bit per level up.", 1], 
				"upg3.4" : [3, 15, "Even More Gains", "Collecting an objective now grants free bits.", 2],
				"upg3.5" : [3, 30, "Textured Files", "Objective Files will now have a different texture.", 3],
				"upg3.6" : [3, 65, "Hyper Bits", "Gain double the bits from all sources.", 5],
				"upg3.7" : [3, 25, "Faster Leveling", "When leveling up go up 2 levels instead of 1, but don't gain the extra bits.", 4],
				"upg3.8" : [3, 35, "Cross-Regional", "Allows you to pick 3 upgrades from the opposite branch.", 4],
				"upg3.9" : [3, 50, "Timed Runs", "Completing the level faster grants a multiplier to Bits gained.", 6]};
				
				
@onready var displayedUpgradeCount = 0;
@onready var numToType = {1: "a", 2: "i", 3: "n"}; # a = active, i = idle, n = neutral
@onready var typeToNum = {"a": 1, "i": 2, "n": 3};
@onready var emptySlots = [];
@onready var displayedUpgrades = [];

# Called when the node enters the scene tree for the first time.
func _ready():
	setDisplay();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	columns = clamp(displayedUpgradeCount, 2, 3);
	updateDisplay();

func setDisplay():
	displayedUpgradeCount = 0;
	var specificUpgCount = {1: 0, 2: 0, 3: 0};
	for upgradeData in upgrades:
		if(upgrades[upgradeData][4] == 0):
			displayedUpgradeCount += 1;
			
			var upgradeObject = upgradeObjectScene.instantiate();
			add_child(upgradeObject);
			var type = upgrades[upgradeData][0];
			
			var id = numToType[type] + str(specificUpgCount[type]+1);
			specificUpgCount[type] += 1;
			
			upgradeObject.setParams(type, upgrades[upgradeData][1], upgrades[upgradeData][2], upgrades[upgradeData][3], id);
			displayedUpgrades.append(id);
		
	addEmptySlots();

func updateDisplay():
	var boughtUpgrades = get_tree().root.get_child(0).getUpgrades();
	var specificUpgCount = {1: 0, 2: 0, 3: 0};
	var upgCount2 = {1: 0, 2: 0, 3: 0};
	for upgrade in boughtUpgrades:
		specificUpgCount[typeToNum[upgrade[0]]] += 1;
	
	for upgradeData in upgrades:
		var needed = upgrades[upgradeData][4];
		var type = upgrades[upgradeData][0];
		upgCount2[type]+=1;
		var id = str(numToType[type]) + str(upgCount2[type]);
		if(displayedUpgrades.has(id)):
			continue;
		
		if(specificUpgCount[type] >= needed):
			displayedUpgradeCount += 1;
			displayedUpgrades.append(id);
			var emptySlot = emptySlots[0];
			emptySlots.remove_at(0);
			
			emptySlot.setParams(type, upgrades[upgradeData][1], upgrades[upgradeData][2], upgrades[upgradeData][3], id);
			emptySlot.appear();
			
			var newEmptySlots = 3 - floor(emptySlots.size() / 3);
			for i in newEmptySlots * 3:
				var upgradeObject = upgradeObjectScene.instantiate();
				add_child(upgradeObject);
				upgradeObject.setParams(0, 0, "", "", "");
				emptySlots.append(upgradeObject);

func addEmptySlots():
	var emptySlotCount = roundi((15 - displayedUpgradeCount) / 3) * 3 - displayedUpgradeCount;
	for i in emptySlotCount:
		
		var upgradeObject = upgradeObjectScene.instantiate();
		add_child(upgradeObject);
		upgradeObject.setParams(0, 0, "", "", "");
		
		emptySlots.append(upgradeObject);
	
