extends Control

@onready var arrow: TextureRect = $MarginContainer/backgroundRect/arrow_rect
@onready var hit_rect: ColorRect = $MarginContainer/hitRect
@onready var arrow_hit_zone: ColorRect = $MarginContainer/backgroundRect/arrow_rect/ColorRect


@onready var bar_container: MarginContainer = $MarginContainer
var start_position: float
var screen_zoom:float
var tween
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.lose_of_hitbar.connect(lose_hitbar)
	start_position = arrow.position.x
	screen_zoom = get_viewport().size.x/640
	print("start_position: ", start_position )
	
	

func lose_hitbar():
	print("connected")
	var hit_size:float
	hit_size =clamp(hit_rect.custom_minimum_size.x - 1,1,50)
	get_tree().create_tween().tween_property(hit_rect,"custom_minimum_size:x",hit_size,0.3)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if arrow.position.x == start_position:
		tween = get_tree().create_tween()
		move_arrow()
	if Input.is_action_just_pressed("ui_accept") and tween.is_valid():
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
			
	if !tween.is_valid() and Input.is_action_just_pressed("ui_accept"):
		tween = get_tree().create_tween()
		move_arrow(310,0,(310 - arrow.position.x)*2/310)

func move_arrow(end_pos:float = 310,start_pos:float = 0,speed:float = 2):
	tween.tween_property(arrow,"position:x",end_pos,speed)
	tween.tween_property(arrow,"position:x",start_pos,2)
	
	
