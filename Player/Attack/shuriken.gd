extends Area2D

# Сюрикен - возвращающиеся метательные звезды
var level = 1
var damage = 6
var knockback_amount = 90
var attack_size = 1.0
var speed = 200.0  # 200.0 * 1.3 = 260
var return_speed = 150.0
var max_distance = 400.0  # Максимальная дистанция полета

var target = Vector2.ZERO
var angle = Vector2.ZERO
var is_returning = false
var start_position = Vector2.ZERO
var hit_enemies = []  # Список уже пораженных врагов

@onready var player = get_tree().get_first_node_in_group("player")
@onready var sprite = $Sprite2D

# signal remove_from_array(object)  # Не используется, закомментировано

func _ready():
	add_to_group("attack")
	collision_layer = 4
	collision_mask = 0
	update_shuriken()
	
	if player:
		start_position = player.global_position
		global_position = start_position
		target = get_random_target()
		if target != Vector2.ZERO:
			angle = global_position.direction_to(target)
			rotation = angle.angle() + PI / 4
		else:
			queue_free()
	else:
		queue_free()

func update_shuriken():
	if not player:
		return
	
	match level:
		1:
			damage = 6
			knockback_amount = 90
			attack_size = 1.0 * (1 + player.spell_size)
			speed = 260.0  # 200.0 * 1.3
			max_distance = 400.0
		2:
			damage = 7
			knockback_amount = 100
			attack_size = 1.1 * (1 + player.spell_size)
			speed = 280.0
			max_distance = 450.0
		3:
			damage = 9
			knockback_amount = 110
			attack_size = 1.2 * (1 + player.spell_size)
			speed = 300.0
			max_distance = 500.0
		4:
			damage = 12
			knockback_amount = 120
			attack_size = 1.3 * (1 + player.spell_size)
			speed = 320.0
			max_distance = 550.0
	
	scale = Vector2(1.0, 1.0) * attack_size

func get_random_target():
	if not player:
		return Vector2.ZERO
	
	var enemies = get_tree().get_nodes_in_group("enemy")
	var bosses = get_tree().get_nodes_in_group("boss")
	var all_targets = enemies + bosses
	
	if all_targets.size() == 0:
		# Если врагов нет, летим в случайном направлении
		var random_angle = randf() * TAU
		return global_position + Vector2(cos(random_angle), sin(random_angle)) * 300.0
	
	var target_enemy = all_targets[randi() % all_targets.size()]
	return target_enemy.global_position

func _physics_process(delta):
	if not player:
		queue_free()
		return
	
	var distance_from_start = global_position.distance_to(start_position)
	
	if not is_returning:
		# Летим к цели
		if target != Vector2.ZERO:
			var distance_to_target = global_position.distance_to(target)
			if distance_to_target < 10.0 or distance_from_start >= max_distance:
				# Достигли цели или максимальной дистанции - возвращаемся
				is_returning = true
			else:
				global_position += angle * speed * delta
				rotation += delta * 15.0  # Быстрое вращение для сюрикена
		else:
			# Если цели нет, возвращаемся
			is_returning = true
	else:
		# Возвращаемся к игроку
		var return_angle = global_position.direction_to(player.global_position)
		global_position += return_angle * return_speed * delta
		rotation += delta * 10.0  # Вращение
		
		# Если вернулись к игроку, удаляемся
		if global_position.distance_to(player.global_position) < 20.0:
			queue_free()

func _on_area_entered(area):
	# Проверяем, попали ли в врага
	var enemy = null
	if area.is_in_group("enemy") or area.is_in_group("boss"):
		enemy = area
	elif area.get_parent() and is_instance_valid(area.get_parent()):
		var parent = area.get_parent()
		if parent.is_in_group("enemy") or parent.is_in_group("boss"):
			enemy = parent
	
	if enemy and is_instance_valid(enemy) and enemy not in hit_enemies:
		hit_enemies.append(enemy)
		if enemy.has_method("_on_hurt_box_hurt"):
			var direction = global_position.direction_to(enemy.global_position)
			enemy._on_hurt_box_hurt(damage, direction, knockback_amount)
		
		# После попадания продолжаем лететь (можем попасть в несколько врагов)
		# Возвращаемся только когда достигли цели или максимальной дистанции
