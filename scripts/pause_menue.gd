extends UI
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var pause_screen: NinePatchRect = $pause_menue/pause_screen
@onready var Scene_transition: Control = $CanvasLayer/scene_transition

@export var pause_button: Button
@export var resume_button: Button
@export var to_main_button:Button
var pause_buttons:Array = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pause_buttons = [to_main_button,pause_button,resume_button]
	for button in pause_buttons:
		button.pivot_offset = button.size / 2


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for button in pause_buttons:
		if button.is_hovered():
			tween_scale(button,1.1,0.2)
		else:
			tween_scale(button,1,0.2)
	if Input.is_action_just_pressed("ui_cancel"):
		handle_anim(pause_screen)


func handle_anim(object):
	
	if !object.visible:
		anim.play("open_"+str(object.name))
		print("handling_anim",str(object.name),anim.is_playing())
	else:
		anim.play("close_"+str(object.name))


func _on_pause_button_pressed() -> void:
	press.play()
	get_tree().paused = !get_tree().paused
	handle_anim(pause_screen)
	
	

func _on_to_main_button_pressed() -> void:
	Scene_transition.anim.play("fade_in")
	await Scene_transition.anim.animation_finished
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menue.tscn")
	
