extends RigidBody2D

func _physics_process(delta):
	set_mode(MODE_RIGID) #Turn back on in case the player set us to MODE_STATIC
