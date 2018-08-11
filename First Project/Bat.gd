extends RigidBody2D

var cached_vel_lin = Vector2()
var cached_vel_ang = 0
var frozen = false

func freeze():
	cached_vel_lin = linear_velocity
	cached_vel_ang = angular_velocity
	set_mode(MODE_STATIC)
	frozen = true

func _physics_process(delta):
	if frozen:
		set_mode(MODE_RIGID)
		frozen = false

func _integrate_forces(state):
	if frozen:
		state.linear_velocity = cached_vel_lin
		state.angular_velocity = cached_vel_ang
