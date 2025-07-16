extends Node2D
@onready var scene_transition: Control = $scene_transition


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Dialogic.signal_event.connect(on_event)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_event(arg: String):
	if arg == "restart_game":
		scene_transition.anim.play("fade_in")
		await scene_transition.anim.animation_finished
		get_tree().reload_current_scene()
