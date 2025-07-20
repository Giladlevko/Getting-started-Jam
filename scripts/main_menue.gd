extends Control
class_name UI
@export var scene_transition: Control
@onready var hover: AudioStreamPlayer = $audio/hover
@onready var press: AudioStreamPlayer = $audio/press
var buttons: Array = []
@export var play_button: Button
@export var credits_button: Button
@export var quit_button: Button
@export var music: AudioStreamPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.transition_finished.connect(on_anim_finished)
	buttons = [play_button,quit_button,credits_button]
	for button in buttons:
		button.pivot_offset = button.size / 2
	on_anim_finished()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	for button in buttons:
		if button.is_hovered():
			tween_scale(button,1.2,0.3)
			
		else:
			tween_scale(button,1,0.3)
	pass
func tween_scale(object,final,dur,bind_object:Node = self):
	var tween = get_tree().create_tween().bind_node(bind_object)
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
	

func on_anim_finished(_anim_name: String = "fade_out"):
	print("connected")
	if music.volume_db == -75:
		var tween = get_tree().create_tween()
		tween.tween_property(music,"volume_db",-14,1).set_ease(Tween.EASE_IN_OUT)
