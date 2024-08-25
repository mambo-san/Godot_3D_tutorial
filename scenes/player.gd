extends CharacterBody3D

# Player speed
@export var speed = 14
#Gravity (downward acceleration speed in Meter/sec)
@export var fall_acceleration = 75
@export var jump_impulse = 20
@export var bounce_impulse = 16 
var bounce_combo = 1;

var target_velocity = Vector3.ZERO

signal hit

func _physics_process(delta):
	var direction = Vector3.ZERO
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
	if Input.is_action_pressed("move_back"):
		direction.z += 1
		
	if direction != Vector3.ZERO:
		#In case user press 2 keys (E.g. up and right, we don't want player to move faster):
		direction = direction.normalized()	
		$Pivot.basis = Basis.looking_at(direction)
		$AnimationPlayer.speed_scale = 4
	else:
		$AnimationPlayer.speed_scale = 1
		
	#Ground Velocity
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed
	#Jump
	if is_on_floor() and Input.is_action_pressed("jump"):
		target_velocity.y = jump_impulse
	#Gravity
	if not is_on_floor():
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)
	#Move the character	
	velocity = target_velocity
	move_and_slide()
	#Collision detection - move_and_slid() may have caused mutiple collisions.
	for index in range(get_slide_collision_count()):
		#Get the collision info 
		var collision = get_slide_collision(index)
		#Check if it was a wall (why does wall collision return null? - What property controls this?)
		if collision.get_collider() == null:
			continue
		if collision.get_collider().is_in_group("mob"):
			var mob = collision.get_collider()
			#Get the angle of collion (represented between 0 and 1 for each of x,y,z) and inspect the UP
			if Vector3.UP.dot(collision.get_normal()) > 0.1: #anything 0.1 and above should be "roughly up")
				mob.squash()
				break
	
	$Pivot.rotation.x = PI / 6 * velocity.y /2 #Flips when jumping

func die():
	hit.emit()
	queue_free()

func _on_mob_detector_body_entered(body):
	die()
