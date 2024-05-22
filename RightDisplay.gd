extends PanelContainer

@onready var bit_display = %"Bit Display"
@onready var news_display = %"News Display"
@onready var file_contents = %"File Contents"

@onready var rng = RandomNumberGenerator.new();

var newsList;
var newsTextI;
var currentNews;
var newsSpeed;

# Called when the node enters the scene tree for the first time.
func _ready():
	newsList = ["This is a message...", "Testing Testing", "Hello!", ":o"];
	newsTextI = -500;
	pickNews();


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	news_display.set_text(currentNews);
	newsTextI = lerp(float(newsTextI), float(newsTextI + delta*5), newsSpeed);
	
	news_display.set_position(Vector2(newsTextI*-1, 0.0));
	
	if(newsTextI >= 1500):
		pickNews();
		newsTextI = -500;
	


func display_bits(bits):
	if(bits == 1):
		bit_display.set_text("You have " + str(bits) + " bit.");
	else:
		bit_display.set_text("You have " + str(bits) + " bits.");

func pickNews():
	newsSpeed = rng.randf_range(8, 35);
	var oldNews = currentNews;
	if(oldNews != null):
		newsList.erase(oldNews);
	
	currentNews = newsList.pick_random();
	
	if(oldNews != null):
		newsList.append(oldNews);
	
func getContents(selected, isObjective):
	file_contents.getContents(selected, isObjective);

func clearFileData():
	file_contents.clearData();
