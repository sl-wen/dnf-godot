extends "on_ground.gd"

#Y方向移动速度
@export var max_yspeed: float = 180
@export var max_walk_speed: float = 150
@export var max_run_speed: float = 300

var is_run:bool = false;

func enter():
	if GlobalManager.map_type == "town":
		max_walk_speed = 300;
	else:
		max_walk_speed = 150;
	
	speed = 0.0
	velocity = Vector2()

	var input_direction = get_input_direction()
	update_look_direction(input_direction)
	owner.get_node("AnimationPlayer").play("move")


func handle_input(event):
	return super.handle_input(event)


func update(_delta):
	var input_direction = get_input_direction()
	if not input_direction:
		is_run = false;
		emit_signal("finished", "idle")
	if owner.get_node("StateMachine").current_state == owner.get_node("StateMachine").move:
		update_look_direction(input_direction)


		if Input.is_action_just_pressed("run") and GlobalManager.map_type != "town": 
			is_run = true;
		
		if is_run: 
			owner.get_node("AnimationPlayer").play("dash");
			speed = max_run_speed
		else:
			owner.get_node("AnimationPlayer").play("move")
			speed = max_walk_speed
		var collision_info = move(speed, input_direction)
		if not collision_info:
			return
		if speed == max_run_speed and collision_info.collider.is_in_group("environment"):
			return null


func move(speed, direction):
	velocity.x = direction.normalized().x * speed
	velocity.y = direction.normalized().y * max_yspeed;
	owner.velocity = velocity
	owner.up_direction = Vector2()
	owner.floor_stop_on_slope = true
	owner.max_slides = 2
	owner.move_and_slide()
	owner.velocity
	if owner.get_slide_collision_count() == 0:
		return
	return owner.get_slide_collision(0)
