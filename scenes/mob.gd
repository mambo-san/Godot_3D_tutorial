extends CharacterBody3D

#Min/Max mob speed in meters/sec
@export var min_speed = 10
@export var max_speed = 18

#Signals
signal squashed

func _physics_process(delta):
	move_and_slide()

func initialize(start_position, player_position):
	#Move Node to start_position and look at player
	look_at_from_position(start_position, player_position, Vector3.UP)
	#Rotate by -45~45 degree to it's on always heading towards the player.
	rotate_y(randf_range(-PI/4, PI/4))
	#Random constant speed for mob
	var random_speed = randi_range(min_speed,max_speed)
	#Velocity needs to consider mob's rotation
	velocity = Vector3.FORWARD * random_speed
	velocity = velocity.rotated(Vector3.UP, rotation.y)
	
	$AnimationPlayer.speed_scale = random_speed


func _on_visible_on_screen_notifier_3d_screen_exited():
	queue_free()

func squash():
	squashed.emit()
	queue_free()
