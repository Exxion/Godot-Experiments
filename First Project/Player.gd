extends RigidBody2D

export(float, -1, 1) var max_floor_normal_y
export(float) var jump_speed
export(int) var max_jumps

export(float) var ground_accel
export(float) var air_accel
export(float) var ground_decel
export(float) var air_decel
export(float) var max_speed
export(float) var bat_offset_scale #How much the distance of the mouse from the player affects the bat offset
export(float) var max_bat_offset

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
	var target_vel = movedir * max_speed
	var dv
	if state.linear_velocity.x * movedir >= target_vel * movedir: #If we're already faster than the target movement speed (or we're not trying to move), use the decel values.
		dv = -ground_decel if on_floor else -air_decel
		dv *= sign(state.linear_velocity.x)
	else: #Otherwise, use the accel values.
		dv = ground_accel if on_floor else air_accel
		dv *= movedir
	dv *= state.step
	var dv_max = abs(state.linear_velocity.x - target_vel)
	dv = clamp(dv, -dv_max, dv_max)
	state.linear_velocity.x += dv
	
	if Input.is_action_pressed("attack"):
		$BatHolder.constant_linear_velocity = (get_local_mouse_position() * bat_offset_scale).clamped(max_bat_offset)
	else:
		$BatHolder.constant_linear_velocity = Vector2()
	
	var cached_pos = state.transform.origin
	state.transform.origin.x = fposmod(state.transform.origin.x, get_viewport().get_visible_rect().size.x)
	state.transform.origin.y = fmod(state.transform.origin.y, get_viewport().get_visible_rect().size.y) #You can fly upwards off the screen, but not downwards.
	if (state.transform.origin - cached_pos).length():
		bat.freeze() #Prevents the pin joint from going nuclear if we wrap around the level. The bat will turn itself back on before the next physics frame.
