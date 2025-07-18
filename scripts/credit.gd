extends UI
@export var return_button: Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#return_button.mouse_entered.connect(on_button_mouse_entered,return_button)
	return_button.pivot_offset = return_button.size / 2


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if return_button.is_hovered():
		tween_scale(return_button,1.1,0.3)
	else: 
		tween_scale(return_button,1,0.3)

func _on_return_button_pressed() -> void:
	press.play()
	scene_transition.anim.play("fade_in")
	await scene_transition.anim.animation_finished
	get_tree().change_scene_to_file("res://scenes/main_menue.tscn")
