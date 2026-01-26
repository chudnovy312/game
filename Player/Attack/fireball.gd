extends Area2D

# Огненный шар, который взрывается при попадании
var level = 1
var hp = 1
var speed = 150
var damage = 10
var knockback_amount = 100
var attack_size = 1.0
var explosion_radius = 50.0

var target = Vector2.ZERO
var angle = Vector2.ZERO

@onready var player = get_tree().get_first_node_in_group("player")
signal remove_from_array(object)

func _ready():
	angle = global_position.direction_to(target)
	rotation = angle.angle() + deg_to_rad(90)
	
	match level:
		1:
			hp = 1
			speed = 150
			damage = 10
			knockback_amount = 100
			attack_size = 1.0 * (1 + player.spell_size)
			explosion_radius = 50.0
		2:
			hp = 1
			speed = 150
			damage = 10
			knockback_amount = 100
			attack_size = 1.0 * (1 + player.spell_size)
			explosion_radius = 50.0
		3:
			hp = 1
			speed = 150
			damage = 15
			knockback_amount = 120
			attack_size = 1.2 * (1 + player.spell_size)
			explosion_radius = 80.0
		4:
			hp = 1
			speed = 150
			damage = 15
			knockback_amount = 120
			attack_size = 1.2 * (1 + player.spell_size)
			explosion_radius = 80.0
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1, 1) * attack_size, 0.3).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()

func _physics_process(delta):
	position += angle * speed * delta

func enemy_hit(charge = 1):
	hp -= charge
	if hp <= 0:
		explode()

func explode():
	# Взрыв наносит урон в радиусе
	# Используем Area2D для поиска врагов в радиусе
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	var circle = CircleShape2D.new()
	circle.radius = explosion_radius
	query.shape = circle
	query.transform = Transform2D(0, global_position)
	query.collision_mask = 4  # Враги (слой атак)
	
	var results = space_state.intersect_shape(query)  # Получаем результаты
	for result in results:
		var body = result.collider
		# Проверяем, является ли это врагом или боссом
		if body:
			# Проверяем группы и наличие метода
			if (body.is_in_group("enemy") or body.is_in_group("boss")) and body.has_method("_on_hurt_box_hurt"):
				var direction = global_position.direction_to(body.global_position)
				body._on_hurt_box_hurt(damage, direction, knockback_amount)
	
	emit_signal("remove_from_array", self)
	queue_free()

func _on_timer_timeout():
	# Взрывается по таймеру, если не попал
	explode()
