extends CharacterBody2D

var speed_level:int
var SPEED = 0
const JUMP_VELOCITY = -400.0
var lost_impetus: float = 10
func _ready() -> void:
	SignalBus.add_speed.connect(speed_up)
	SignalBus.reduct_speed.connect(slow_down)
	

func slow_down():
	speed_level = clamp(speed_level-1,0,50)
	lost_impetus = 0
	SPEED = clamp(speed_level*10,0,500)

func speed_up():
	speed_level = clamp(speed_level + 1,0,50)
	lost_impetus = 10
	SPEED = clamp(speed_level*10,0,500)
	print(SPEED,"-speed")

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	velocity.x = SPEED
	rotation += ((velocity.x)/30) * delta
	SPEED = move_toward(SPEED, 0, delta)
	if SPEED > 0:
		lost_impetus = move_toward(lost_impetus,0,delta)
	if snapped(lost_impetus,0.1) == 0 or lost_impetus == 0:
		SignalBus.lose_of_hitbar.emit()
		speed_level = clamp(speed_level-1,0,50)
		lost_impetus = 10
	move_and_slide()
