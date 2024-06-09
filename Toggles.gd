extends PanelContainer

@onready var right_display = $"../../.."
@onready var auto_folder_toggle = %AutoFolderToggle
@onready var auto_complete_toggle = %AutoCompleteToggle

@onready var viewableToggles = ["news"];

# Called when the node enters the scene tree for the first time.
func _ready():
	pass;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	#updates the visibility of certain toggles if the user has the respective upgrade
	auto_folder_toggle.visible = viewableToggles.has("auto-open");
	auto_complete_toggle.visible = viewableToggles.has("auto-complete");
		
#updates the viewable toggle list if the user has certain upgrades from the given upgrade list
func update(upgrades):
	if(upgrades.has("i3") && !viewableToggles.has("auto-open")):
		viewableToggles.append("auto-open");
		
	if(upgrades.has("i4") && !viewableToggles.has("auto-complete")):
		viewableToggles.append("auto-complete");

#sends out toggle updates to the neccesary parts of the code when the respective toggle gets toggled

func _on_auto_folder_toggle_toggled(toggled_on):
	updateRightDisplay(toggled_on, "auto-open");

func _on_news_toggle_toggled(toggled_on):
	updateRightDisplay(toggled_on, "news");

func _on_auto_complete_toggle_toggled(toggled_on):
	updateRightDisplay(toggled_on, "auto-complete");

func _on_screen_shake_toggle_toggled(toggled_on):
	updateRightDisplay(toggled_on, "screenshake");

#updates the toggle list in right_display given whether the toggle is on or off and its tyoe
func updateRightDisplay(toggled_on, type):
	right_display.toggleThing(toggled_on, type);
