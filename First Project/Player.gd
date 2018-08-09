extends RigidBody2D

export(float, -1, 1) var max_floor_normal_y
export(float) var jump_speed
export(int) var max_jumps

export(float) var ground_accel
export(float) var air_accel
export(float) var ground_decel
export(float) var air_decel
export(float) var max_speed

var jumps_left = 0
var jumping = false

onready var bat = $Bat

func _integrate_forces(state):
	var on_floor = false
	for i in range(state.get_contact_count()):
		if state.get_contact_local_normal(i).y <= max_floor_normal_y:
			on_floor = true
			break
	
	if on_floor:
		if jumping:
			jumping = false #A full frame elapses between the input and actually leaving the ground, so this serves to prevent jumps from refreshing then.
		else:
			jumps_left = max_jumps
	
	if Input.is_action_just_pressed("jump"):
		if jumps_left:
			state.linear_velocity.y = -jump_speed
			jumps_left -= 1
			jumping = true #Yes, this really is the only way to do it. (As far as I know.)
	
	var movedir = 0
	if Input.is_action_pressed("move_left"):
		movedir -= 1
	if Input.is_action_pressed("move_right"):
		movedir += 1
	if movedir:
		movedir *= state.step
		if on_floor:
			movedir *= ground_accel
		else:
			movedir *= air_accel
		state.linear_velocity.x += movedir
		state.linear_velocity.x = clamp(state.linear_velocity.x, -max_speed, max_speed)
	else:
		movedir = -sign(state.linear_velocity.x)
		movedir *= state.step
		if on_floor:
			movedir *= ground_decel
		else:
			movedir *= air_decel
		if(abs(movedir) > abs(state.linear_velocity.x)):
			state.linear_velocity.x = 0
		else:
			state.linear_velocity.x += movedir
	
	state.transform.origin.x = fposmod(state.transform.origin.x, get_viewport().size.x)
	state.transform.origin.y = fposmod(state.transform.origin.y, get_viewport().size.y)
