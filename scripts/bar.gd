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

var start_position: float
var screen_zoom:float
var tween
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.visible = false
	Dialogic.signal_event.connect(start_timer)
	SignalBus.lose_of_hitbar.connect(lose_hitbar)
	start_position = arrow.position.x
	screen_zoom = get_viewport().size.x/640
	print("start_position: ", start_position)
	
	

func stop_timer():
	timer.stop()
	anim.play("fade_out")

func start_timer(arg: String):
	if arg == "start_timer":
		anim.play("fade_in")
		await anim.animation_finished
		if !timer_started:
			timer.start()
			label.visible = true
			timer_started = true
			bar_started = true
	if arg == "stop_timer":
		stop_timer()

func lose_hitbar():
	print("connected")
	var hit_size:float
	hit_size =clamp(hit_rect.custom_minimum_size.x - 1,1,50)
	get_tree().create_tween().tween_property(hit_rect,"custom_minimum_size:x",hit_size,0.3)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if arrow.position.x == start_position and bar_started:
		tween = get_tree().create_tween()
		move_arrow()
	if tween and Input.is_action_just_pressed("ui_accept") and tween.is_valid():
		var hit_size:float
		tween.kill()
		if arrow_hit_zone.get_global_rect().intersects(hit_rect.get_global_rect()):
			print("---------------you-won---------------")
			SignalBus.add_speed.emit()
			hit_size =clamp(hit_rect.custom_minimum_size.x + 1,1,50)
			get_tree().create_tween().tween_property(hit_rect,"custom_minimum_size:x",hit_size,0.3)
			
			
		else:
			SignalBus.reduct_speed.emit()
			print("---------------you-lose---------------")
			
	if tween and !tween.is_valid() and Input.is_action_just_pressed("ui_accept"):
		tween = get_tree().create_tween()
		move_arrow(310,0,(310 - arrow.position.x)*2/310)
	
	timer_sec = snapped(timer.wait_time-timer.time_left -60 * timer_min,0.1)
	if snapped(timer_sec,0.1) == 60:
		timer_min += 1
		timer_sec = 0
		Global.timer_value = timer_min
	var mili_sec = str(timer_sec).split(".")[1]
	var sec = str(timer_sec).split(".")[0]
	label.text = str(timer_min)+":"+str(sec) +":" + str(mili_sec)
	
func move_arrow(end_pos:float = 310,start_pos:float = 0,speed:float = 2):
	tween.tween_property(arrow,"position:x",end_pos,speed)
	tween.tween_property(arrow,"position:x",start_pos,2)
	
	
