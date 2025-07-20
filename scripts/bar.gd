extends Control

@onready var arrow: TextureRect = $MarginContainer/backgroundRect/arrow_rect
@onready var hit_rect: ColorRect = $MarginContainer/hitRect
@onready var arrow_hit_zone: ColorRect = $MarginContainer/backgroundRect/arrow_rect/ColorRect
var timer_started:bool
var bar_started: bool
@onready var bar_container: MarginContainer = $MarginContainer
@onready var label: Label = $"../../../MarginContainer2/Label"
@onready var timer: Timer = $"../../../MarginContainer2/Label/Timer"
@onready var anim: AnimationPlayer = $AnimationPlayer
var timer_sec:float
var timer_min:int
@onready var music: AudioStreamPlayer = $"../../../../../audio/music"
@onready var success: AudioStreamPlayer = $"../../../../../audio/success"
@onready var fail: AudioStreamPlayer = $"../../../../../audio/fail"

var arrow_dir: int = 1
var start_position: float
var screen_zoom:float
var tween
var end_position:int = 310
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.visible = false
	Dialogic.signal_event.connect(start_timer)
	SignalBus.lose_of_hitbar.connect(lose_hitbar)
	SignalBus.reached_end.connect(on_reached_end)
	start_position = arrow.position.x
	screen_zoom = get_viewport().size.x/640
	print("start_position: ", start_position)
	
	

func on_reached_end():
	print("bar connected")
	timer.paused = true
	var tween_music = get_tree().create_tween().bind_node(self)
	tween_music.tween_property(music,"volume_db",-40,2)
	anim.play("fade_out")
	bar_started = false



func start_timer(arg: String):
	if arg == "start_timer":
		music.play()
		var tween_music = get_tree().create_tween().bind_node(self)
		tween_music.tween_property(music,"volume_db",-13,6)
		anim.play("fade_in")
		await anim.animation_finished
		if !timer_started:
			timer.start()
			label.visible = true
			timer_started = true
			bar_started = true


func lose_hitbar():
	print("connected")
	var hit_size:float
	hit_size =clamp(hit_rect.custom_minimum_size.x - 1,1,50)
	get_tree().create_tween().bind_node(self).tween_property(hit_rect,"custom_minimum_size:x",hit_size,0.3)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if arrow.position.x == start_position and bar_started:
		tween = get_tree().create_tween()
		move_arrow()
	if tween and Input.is_action_just_pressed("space") and tween.is_valid() and bar_started:
		var hit_size:float
		tween.kill()
		if arrow_hit_zone.get_global_rect().intersects(hit_rect.get_global_rect()):
			print("---------------you-won---------------")
			SignalBus.add_speed.emit()
			hit_size =clamp(hit_rect.custom_minimum_size.x + 1,1,50)
			get_tree().create_tween().tween_property(hit_rect,"custom_minimum_size:x",hit_size,0.3)
			success.play()
			
		else:
			SignalBus.reduct_speed.emit()
			fail.play()
			print("---------------you-lose---------------")
			
	if tween and !tween.is_valid() and Input.is_action_just_pressed("space") and bar_started:
		tween = get_tree().create_tween()
		tween.bind_node(self)
		
		if arrow_dir == 1:
			move_arrow(end_position,0,(end_position - arrow.position.x)*2/end_position)
		else:
			move_arrow(start_position,end_position,(abs((start_position - arrow.position.x)*2/end_position)),false)
	timer_sec = snapped(timer.wait_time-timer.time_left -60 * timer_min,0.1)
	if snapped(timer_sec,0.1) == 60:
		timer_min += 1
		timer_sec = 0
		Global.timer_value = timer_min
	var mili_sec = str(timer_sec).split(".")[1]
	var sec = str(timer_sec).split(".")[0]
	label.text = str(timer_min)+":"+str(sec) +":" + str(mili_sec)
	
	
	if tween and tween.is_valid():
		if round(arrow.position.x) == start_position:
			arrow_dir = 1
		if round(arrow.position.x) == end_position:
			arrow_dir = -1


func move_arrow(end_pos:float = 310,start_pos:float = 0,speed:float = 2,second_tween_on:bool = true):
	tween.tween_property(arrow,"position:x",end_pos,speed)
	if second_tween_on:
		tween.tween_property(arrow,"position:x",start_pos,2)
	tween.bind_node(self)
	
