extends RayCast

onready var body_car : RigidBody = get_parent()

export var tyre_pressure : float = 100
export var tyre_damp : float = 10

var collision_point : Vector3 = Vector3()
onready var prev_length : float = abs(cast_to.y)
var force_y : float = 0.0

func _ready():
	add_exception(body_car)


func wheel_contact(delta) -> bool:
	if is_colliding():
		var basis_y : Vector3  = global_transform.basis.y
		var rest_length : float = abs(cast_to.y)
		var collision_point : Vector3 = get_collision_point()
		var curr_length : float = global_transform.origin.distance_to(collision_point)
		var speed_y : float = (prev_length - curr_length)/delta
		var up_force : float = (rest_length - curr_length)*tyre_pressure
		var damp_force : float = speed_y*tyre_damp
		
		force_y = up_force + damp_force
		#body_car.add_force(basis_y * force_y,body_car.to_local(global_transform.origin))
		#apply_impulse(transform.basis.xform(Vector3(0,2,0)), transform.basis.x)
		body_car.add_force(basis_y * force_y,body_car.transform.basis.xform(translation))
		prev_length = curr_length
		return true
	else:
		prev_length = abs(cast_to.y)
		return false
