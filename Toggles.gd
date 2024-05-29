extends PanelContainer

@onready var right_display = $"../../.."

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_news_toggle_toggled(toggled_on):
	right_display.toggleNews(toggled_on);
