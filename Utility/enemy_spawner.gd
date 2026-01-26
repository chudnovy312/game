extends Node2D

# Новая система спавна на основе уровня игрока
@export var spawn_rate_base = 2.0  # Базовый интервал спавна (секунды)
@export var spawn_rate_per_level = 0.05  # Уменьшение интервала за уровень (более плавное)
@export var enemies_per_spawn_base = 1  # Базовое количество врагов за спавн

@onready var player = get_tree().get_first_node_in_group("player")

@export var time = 0
var spawn_timer = 0.0
var last_player_level = 1

signal changetime(time)

# Boss spawning
var boss_scene = preload("res://Enemy/boss_knight.tscn")
var last_boss_level = 0  # Отслеживаем последний уровень, на котором заспавнили босса

# Chest spawning
var chest_scene = preload("res://Objects/chest.tscn")
var chest_spawn_timer = 0.0
var chest_spawn_interval = 60.0  # Каждые 60 секунд

func _ready():
	connect("changetime",Callable(player,"change_time"))
	# Подписываемся на изменение уровня игрока
	if player:
		player.connect("level_changed", Callable(self, "_on_player_level_changed"))
		last_player_level = player.experience_level

func _on_timer_timeout():
	time += 1
	emit_signal("changetime",time)

func _process(delta):
	# Проверяем спавн сундука
	chest_spawn_timer += delta
	check_chest_spawn()
	
	# Новая система спавна врагов на основе уровня
	if not player:
		return
	
	var current_level = player.experience_level
	
	# Обновляем спавн при изменении уровня
	if current_level != last_player_level:
		last_player_level = current_level
		spawn_timer = 0.0  # Сбрасываем таймер при изменении уровня
	
	# Вычисляем интервал спавна (уменьшается с уровнем, но не слишком быстро)
	var spawn_interval = max(0.3, spawn_rate_base - (current_level * spawn_rate_per_level))
	
	# Вычисляем количество врагов за спавн (увеличивается с уровнем)
	var enemies_per_spawn = enemies_per_spawn_base
	if current_level <= 10:
		enemies_per_spawn = 1 + (current_level / 5)  # 1-3 врага на уровнях 1-10
	elif current_level <= 20:
		enemies_per_spawn = 3 + ((current_level - 10) / 3)  # 3-6 врагов на уровнях 11-20
	else:
		enemies_per_spawn = 6 + ((current_level - 20) / 2)  # 6+ врагов на уровнях 21+
	enemies_per_spawn = int(enemies_per_spawn)
	
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_enemies_by_level(current_level, enemies_per_spawn)
		spawn_timer = 0.0
	
	# Проверяем спавн босса каждые 3 уровня
	check_boss_spawn()

func spawn_enemies_by_level(player_level: int, count: int = 1):
	# Получаем список врагов для текущего уровня
	# Используем прямое обращение к классу, так как это статические функции
	var enemy_levels = EnemySpawnConfig.get_enemies_for_level(player_level)
	
	if enemy_levels.size() == 0:
		return
	
	# Спавним врагов
	for i in range(count):
		# Выбираем случайного врага из доступных для уровня
		var enemy_level = enemy_levels.pick_random()
		var enemy_scene = EnemySpawnConfig.get_enemy_scene(enemy_level)
		
		if enemy_scene:
			var enemy = enemy_scene.instantiate()
			enemy.global_position = get_random_position()
			add_child(enemy)

func get_random_position():
	var vpr = get_viewport_rect().size * randf_range(1.1,1.4)
	var top_left = Vector2(player.global_position.x - vpr.x/2, player.global_position.y - vpr.y/2)
	var top_right = Vector2(player.global_position.x + vpr.x/2, player.global_position.y - vpr.y/2)
	var bottom_left = Vector2(player.global_position.x - vpr.x/2, player.global_position.y + vpr.y/2)
	var bottom_right = Vector2(player.global_position.x + vpr.x/2, player.global_position.y + vpr.y/2)
	var pos_side = ["up","down","right","left"].pick_random()
	var spawn_pos1 = Vector2.ZERO
	var spawn_pos2 = Vector2.ZERO
	
	match pos_side:
		"up":
			spawn_pos1 = top_left
			spawn_pos2 = top_right
		"down":
			spawn_pos1 = bottom_left
			spawn_pos2 = bottom_right
		"right":
			spawn_pos1 = top_right
			spawn_pos2 = bottom_right
		"left":
			spawn_pos1 = top_left
			spawn_pos2 = bottom_left
	
	var x_spawn = randf_range(spawn_pos1.x, spawn_pos2.x)
	var y_spawn = randf_range(spawn_pos1.y,spawn_pos2.y)
	return Vector2(x_spawn,y_spawn)

func check_boss_spawn():
	if not player:
		return
	
	var current_level = player.experience_level
	
	# Спавним босса каждые 3 уровня (3, 6, 9, 12...)
	if current_level > 0 and current_level % 3 == 0 and current_level != last_boss_level:
		# Проверяем, нет ли уже живого босса на сцене
		var existing_bosses = get_tree().get_nodes_in_group("boss")
		if existing_bosses.size() == 0:
			spawn_boss()
			last_boss_level = current_level

func spawn_boss():
	var boss = boss_scene.instantiate()
	boss.global_position = get_random_position()
	add_child(boss)

func _on_player_level_changed(_new_level):
	# Вызывается при изменении уровня игрока
	check_boss_spawn()

func check_chest_spawn():
	if chest_spawn_timer >= chest_spawn_interval:
		spawn_chest()
		chest_spawn_timer = 0.0

func spawn_chest():
	# Спавним сундук не рядом с игроком
	var chest = chest_scene.instantiate()
	var spawn_pos = get_random_position()
	# Убеждаемся, что сундук не слишком близко к игроку
	var min_distance = 200.0
	var attempts = 0
	while spawn_pos.distance_to(player.global_position) < min_distance and attempts < 10:
		spawn_pos = get_random_position()
		attempts += 1
	
	chest.global_position = spawn_pos
	get_parent().add_child(chest)  # Добавляем в World, а не в EnemySpawner
