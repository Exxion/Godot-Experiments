extends RigidBody2D

func _integrate_forces(state):
	state.transform.origin.x = fposmod(state.transform.origin.x, get_viewport().get_visible_rect().size.x)
	state.transform.origin.y = fmod(state.transform.origin.y, get_viewport().get_visible_rect().size.y) #You can fly upwards off the screen, but not downwards.
