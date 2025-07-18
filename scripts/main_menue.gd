extends Control
class_name UI
@onready var scene_transition: Control = $scene_transition
@onready var hover: AudioStreamPlayer = $audio/hover
@onready var press: AudioStreamPlayer = $audio/press
var buttons: Array = []
@export var play_button: Button
@export var credits_button: Button
@export var quit_button: Button
@onready var music: AudioStreamPlayer = $audio/music


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.transition_finished.connect(on_anim_finished)
	buttons = [play_button,quit_button,credits_button]
	for button in buttons:
		button.pivot_offset = button.size / 2
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for button in buttons:
		if button.is_hovered():
			tween_scale(button,1.2,0.3)
			
		else:
			tween_scale(button,1,0.3)
	pass
func tween_scale(object,final,dur):
	var tween = get_tree().create_tween()
	tween.tween_property(object,"scale",final * Vector2.ONE,dur)

func _on_play_button_pressed() -> void:
	press.play()
	scene_transition.anim.play("fade_in")
	await scene_transition.anim.animation_finished
	get_tree().change_scene_to_file("res://scenes/level.tscn")


func _on_credits_button_pressed() -> void:
	press.play()
	scene_transition.anim.play("fade_in")
	await scene_transition.anim.animation_finished
	get_tree().change_scene_to_file("res://scenes/credit.tscn")


func _on_quit_button_pressed() -> void:
	press.play()
	scene_transition.anim.play("fade_in")
	await scene_transition.anim.animation_finished
	get_tree().quit()


func on_button_mouse_entered() -> void:
	hover.play()
	

func on_anim_finished(anim_name):
	print("connected")
	var tween = get_tree().create_tween()
	if music.volume_db == -75:
		tween.tween_property(music,"volume_db",-15,2).set_ease(Tween.EASE_OUT)
	elif music.volume_db > -75:
		tween.tween_property(music,"volume_db",-75,0.3)
		
