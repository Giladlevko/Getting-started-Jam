extends Node

var played_timelines: Dictionary = {}
var timer_value: int = 10
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func modifier(text: String) -> String:
	text = text.replace("amount of time", str(timer_value))
	return text
