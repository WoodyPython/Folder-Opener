extends PanelContainer

#object references
@onready var bit_display = %"Bit Display"
@onready var news_display = %"News Display"
@onready var file_contents = %"File Contents"
@onready var toggles = %Toggles
@onready var main = $"../../../.."

@onready var rng = RandomNumberGenerator.new();

#basic vars
var newsList;
var newsTextI;
var currentNews;
var newsSpeed;

#default list of toggles
@onready var toggleList = ["news", "screenshake", "auto-open", "auto-complete"];

# Called when the node enters the scene tree for the first time.
func _ready():
	
	#sets up the news ticker
	newsList = ["This is a message...", "Testing Testing", "Hello!", ":o"];
	newsTextI = -500;
	pickNews();


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	#updates the toggle list
	main.updateTogglesLeft(toggleList);
	
	#if the user has the news toggle enabled, run the news
	if(toggleList.has("news")):
		
		#sets the news display and moves it across the screen every frame
		news_display.set_text(currentNews);

		newsTextI = lerp(float(newsTextI), float(newsTextI + delta*5), newsSpeed);
		
		news_display.set_position(Vector2(newsTextI*-1, 0.0));
		
		#if the news message goes way offscreen, then pick another news to show
		if(newsTextI >= 1500):
			pickNews();
			newsTextI = -500;
	else:
		news_display.set_text(" ");

#updates the bits display, given the current bits
func display_bits(bits):
	if(bits == 1):
		bit_display.set_text("You have " + str(bits) + " bit.");
	else:
		bit_display.set_text("You have " + str(bits) + " bits.");

#picks a random news message and speed
func pickNews():
	newsSpeed = rng.randf_range(8, 35);
	
	#system to prevent duplicate news showing up twice in a row
	var oldNews = currentNews;
	if(oldNews != null):
		newsList.erase(oldNews);
	
	currentNews = newsList.pick_random();
	
	if(oldNews != null):
		newsList.append(oldNews);

#gets the contents of a clicked file given the file and whether its an objective
func getContents(selected, isObjective):
	file_contents.getContents(selected, isObjective);

#clears the file data from the previous run
func clearFileData():
	file_contents.clearData();

#updates the toggles based on purchased upgrades
func updateToggles(upgrades):
	toggles.update(upgrades);

#toggles the toggle on or off given the toggle and name
func toggleThing(toggle, toggleName):
	if(toggle):
		toggleList.append(toggleName);
	else:
		toggleList.erase(toggleName);
