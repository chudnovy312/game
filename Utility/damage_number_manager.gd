extends Node

# Менеджер всплывающих цифр урона с пулом объектов
const POOL_SIZE = 100
const DAMAGE_NUMBER_SCENE = preload("res://Utility/damage_number.tscn")

var pool: Array[Node2D] = []
var active_numbers: Array[Node2D] = []

@onready var world_root: Node2D = null

func _ready():
	# Создаём пул объектов
	for i in range(POOL_SIZE):
		var damage_number = DAMAGE_NUMBER_SCENE.instantiate()
		damage_number.visible = false
		damage_number.is_active = false
		add_child(damage_number)
		pool.append(damage_number)

func _process(_delta):
	# Находим корень мира при первом запуске
	if world_root == null:
		var world = get_tree().get_first_node_in_group("world")
		if world:
			world_root = world as Node2D
		else:
			# Пытаемся найти через имя
			var root = get_tree().get_root()
			for child in root.get_children():
				if child.name == "World":
					world_root = child as Node2D
					break

# Показать урон
func show_damage(damage: int, global_pos: Vector2, is_crit: bool = false, damage_type: String = "normal"):
	var damage_number = get_from_pool()
	
	if not damage_number:
		# Если пул пуст, создаём новый
		damage_number = DAMAGE_NUMBER_SCENE.instantiate()
		pool.append(damage_number)
	
	# Удаляем из текущего родителя, если есть
	if damage_number.get_parent():
		damage_number.get_parent().remove_child(damage_number)
	
	# Добавляем в активные
	if not active_numbers.has(damage_number):
		active_numbers.append(damage_number)
	
	# Находим целевого родителя (мир)
	var target_parent = world_root
	if not target_parent:
		# Пытаемся найти мир снова
		var world = get_tree().get_first_node_in_group("world")
		if world:
			world_root = world as Node2D
			target_parent = world_root
		else:
			# Если мир не найден, используем корень
			target_parent = get_tree().get_root()
	
	# Добавляем в родителя
	target_parent.add_child(damage_number)
	
	# Настраиваем и показываем (setup установит позицию)
	damage_number.setup(damage, is_crit, damage_type, global_pos)

# Получить объект из пула
func get_from_pool() -> Node2D:
	for number in pool:
		if not number.is_active:
			return number
	return null

# Вернуть объект в пул
func return_to_pool(damage_number: Node2D):
	if damage_number and damage_number.is_in_group("damage_number"):
		damage_number.is_active = false
		damage_number.visible = false
		damage_number.modulate.a = 1.0
		damage_number.scale = Vector2(1.0, 1.0)
		
		if active_numbers.has(damage_number):
			active_numbers.erase(damage_number)
		
		# Удаляем из родителя
		if damage_number.get_parent():
			damage_number.get_parent().remove_child(damage_number)
