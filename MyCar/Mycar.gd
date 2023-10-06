extends RigidBody

export var acceleration : float = 20.0
export var steer_force : float = 5.0
export var steer_curve : Curve
var full_steer_speed : float = 7
export var friction_x : float = 15.0

var speed_input = 0
var rotate_input = 0

onready var wheels = [$"%Wheel", $"%Wheel2", $"%Wheel3", $"%Wheel4"]
onready var particles = [$"%Smoke", $"%Smoke2"]
onready var right_wheel = $sedan/tmpParent/sedan/wheel_frontLeft
onready var left_wheel = $sedan/tmpParent/sedan/wheel_frontRight
onready var force_point = $"%ForcePoint"

var score = 0

func _ready():
	$"%Score".text = "Score = " + str(score)

func _physics_process(delta):
	var contact_wheels = 0
	for wheel in wheels:
		if wheel.wheel_contact(delta) == true:
			contact_wheels += 1
	
	speed_input = 0
	speed_input += Input.get_action_strength("accelerate")
	speed_input -= Input.get_action_strength("brake") 
	
	rotate_input = 0
	rotate_input += Input.get_action_strength("steer_left")
	rotate_input -= Input.get_action_strength("steer_right")
	
	right_wheel.rotation.y = lerp_angle(right_wheel.rotation.y,rotate_input/1.5,0.2)
	left_wheel.rotation.y = lerp_angle(left_wheel.rotation.y,rotate_input/1.5,0.2)
	
	#add_central_force(-global_transform.basis.z * speed_input * acceleration * contact_wheels)
	var force_z = -global_transform.basis.z * speed_input * acceleration * contact_wheels
	add_force(force_z,transform.basis.xform(force_point.translation))
	
	var speed_x = global_transform.basis.xform_inv(linear_velocity).x
	speed_x = clamp(speed_x,-1.0,1.0)
	var force_x = -global_transform.basis.x * speed_x * friction_x * contact_wheels
	add_force(force_x,transform.basis.xform(force_point.translation))
	
	var speed_z = abs(global_transform.basis.xform_inv(linear_velocity).z)
	#print(speed_z)
	var steer_speed_factor = -steer_curve.interpolate_baked(speed_z/full_steer_speed)
	var torque_y = -global_transform.basis.y * rotate_input * steer_force * contact_wheels * steer_speed_factor
	add_torque(torque_y)
	
	process_particles()

func process_particles():
	var d = linear_velocity.normalized().dot(-transform.basis.z)
	print(d)
	if d > 0.0 and d < 0.97:
		score += (1.0 - d)*10.0
		$"%Score".text = "Score = " + str(stepify(score,0.1))
		for part in particles:
			part.emitting = true
			part.emitting = true
	else:
		for part in particles:
			part.emitting = false
