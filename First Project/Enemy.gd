extends RigidBody2D

func _integrate_forces(state):
	state.transform.origin.x = fposmod(state.transform.origin.x, get_viewport().size.x)
	state.transform.origin.y = fposmod(state.transform.origin.y, get_viewport().size.y)
