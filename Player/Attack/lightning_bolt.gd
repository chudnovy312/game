extends Area2D

# Молния - бьет по цепочке врагов
var level = 1
var damage = 8
var knockback_amount = 80
var attack_size = 1.0
var chain_count = 3  # Количество целей в цепочке
var chain_range = 150.0  # Радиус поиска следующей цели
var speed = 400.0  # Скорость молнии

var current_target = null
var hit_enemies = []  # Список уже пораженных врагов
var chain_index = 0

@onready var player = get_tree().get_first_node_in_group("player")
@onready var sprite = $Sprite2D

signal remove_from_array(object)

func _ready():
	add_to_group("attack")
	collision_layer = 4
	collision_mask = 0
	update_lightning()
	# Запускаем поиск цели в следующем кадре, чтобы все узлы были готовы
	call_deferred("find_next_target")

func update_lightning():
	if not player:
		return
	
	match level:
		1:
			damage = 8
			knockback_amount = 80
			attack_size = 1.0 * (1 + player.spell_size)
			chain_count = 3
			chain_range = 150.0
		2:
			damage = 10
			knockback_amount = 90
			attack_size = 1.1 * (1 + player.spell_size)
			chain_count = 4
			chain_range = 180.0
		3:
			damage = 12
			knockback_amount = 100
			attack_size = 1.2 * (1 + player.spell_size)
			chain_count = 5
			chain_range = 200.0
		4:
			damage = 15
			knockback_amount = 120
			attack_size = 1.3 * (1 + player.spell_size)
			chain_count = 6
			chain_range = 220.0
	
	scale = Vector2(1.0, 1.0) * attack_size

func find_next_target():
	if chain_index >= chain_count:
		queue_free()
		return
	
	# Ищем ближайшего врага
	var enemies = get_tree().get_nodes_in_group("enemy")
	var bosses = get_tree().get_nodes_in_group("boss")
	var all_targets = enemies + bosses
	
	var closest_enemy = null
	var closest_distance = INF
	
	for enemy in all_targets:
		if enemy in hit_enemies or not is_instance_valid(enemy):
			continue
		
		var distance = global_position.distance_to(enemy.global_position)
		if distance <= chain_range and distance < closest_distance:
			closest_enemy = enemy
			closest_distance = distance
	
	if closest_enemy:
		current_target = closest_enemy
		hit_enemy(closest_enemy)
	else:
		# Если врагов нет, завершаем
		queue_free()

func hit_enemy(enemy):
	if not enemy or enemy in hit_enemies or not is_instance_valid(enemy):
		# Если враг невалиден, ищем следующего
		find_next_target()
		return
	
	# Наносим урон
	if enemy.has_method("_on_hurt_box_hurt"):
		var direction = global_position.direction_to(enemy.global_position)
		enemy._on_hurt_box_hurt(damage, direction, knockback_amount)
	
	# Перемещаемся к врагу
	global_position = enemy.global_position
	hit_enemies.append(enemy)
	chain_index += 1
	
	# Небольшая задержка перед следующей цепью (визуальный эффект)
	# Используем call_deferred для надежности
	var timer = get_tree().create_timer(0.05)
	timer.timeout.connect(find_next_target)

func _on_area_entered(_area):
	# Не используется, так как мы сами ищем цели
	pass
