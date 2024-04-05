extends CPUParticles2D

var lifespan_start = Time.get_ticks_msec() 

func _process(_delta):
	if Time.get_ticks_msec() - lifespan_start > 5000:
		queue_free()
