extends Node

# Конфигурация спавна врагов по уровням
# Autoload singleton - доступен глобально как EnemySpawnConfig
# Враги пронумерованы: 1=kobold_weak, 2=kobold_strong, 3=cyclops, 4=juggernaut, 5=super, 6=goblin_archer, 7=orc_warrior

static var enemy_scenes = {
	1: preload("res://Enemy/enemy_kobold_weak.tscn"),
	2: preload("res://Enemy/enemy_kobold_strong.tscn"),
	3: preload("res://Enemy/enemy_cyclops.tscn"),
	4: preload("res://Enemy/enemy_juggernaut.tscn"),
	5: preload("res://Enemy/enemy_super.tscn"),
	6: preload("res://Enemy/enemy_goblin_archer.tscn"),  # Новый враг: Гоблин-лучник
	7: preload("res://Enemy/enemy_orc_warrior.tscn")  # Новый враг: Орк-воин
}

# Функция определяет, какие враги должны спавниться на данном уровне игрока
static func get_enemies_for_level(player_level: int) -> Array:
	var enemy_levels = []
	
	if player_level < 10:
		# Логика для уровней 1-9
		match player_level:
			1:
				enemy_levels = [1]
			2:
				enemy_levels = [1, 2]
			3:
				enemy_levels = [1, 2, 3]
			4:
				enemy_levels = [2, 3, 4]
			5:
				enemy_levels = [3, 4, 5]
			6:
				enemy_levels = [4, 5, 6]  # Добавляем гоблина-лучника
			7:
				enemy_levels = [4, 5, 6, 7]  # Добавляем орка-воина
			8:
				enemy_levels = [5, 6, 7]  # Больше новых врагов
			9:
				enemy_levels = [5, 6, 7]  # Смесь сильных врагов
	else:
		# Уровень 10+: спавним смесь сильных врагов
		# На уровнях 10-19: враги 3, 4, 5, 6
		if player_level < 20:
			enemy_levels = [3, 4, 5, 6]
		# На уровнях 20-29: враги 4, 5, 6, 7 (больше новых врагов)
		elif player_level < 30:
			enemy_levels = [4, 5, 6, 7]
			# Добавляем больше супер-врагов
			for i in range(1):
				enemy_levels.append(5)
		# На уровнях 30+: смесь всех сильных врагов
		else:
			enemy_levels = [5, 6, 7]
			# На очень высоких уровнях добавляем больше супер-врагов
			for i in range(min(2, int((player_level - 30) / 5))):
				enemy_levels.append(5)
	
	# Ограничиваем реальными типами врагов (1-7)
	var valid_enemies = []
	for level in enemy_levels:
		if level >= 1 and level <= 7:
			valid_enemies.append(level)
	
	return valid_enemies

# Получить сцену врага по его уровню
static func get_enemy_scene(enemy_level: int) -> PackedScene:
	if enemy_level >= 1 and enemy_level <= 7:
		return enemy_scenes[enemy_level]
	return enemy_scenes[1]  # По умолчанию
