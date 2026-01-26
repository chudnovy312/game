extends Area2D

# Вращающийся меч вокруг игрока
var level = 1
var damage = 8
var knockback_amount = 100
var attack_size = 1.0
var rotation_speed = 3.0  # Скорость вращения
var radius = 60.0  # Радиус вращения
var angle = 0.0  # Текущий угол вращения
var start_angle = 0.0  # Начальный угол для распределения мечей
var attack_angle = Vector2.ZERO  # Направление удара для knockback

@onready var player = get_tree().get_first_node_in_group("player")
@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D

# signal remove_from_array(object)  # Не используется, закомментировано

func _ready():
	add_to_group("attack")  # Добавляем в группу атак
	collision_layer = 4  # Слой атак
	collision_mask = 0
	update_sword()

func update_sword():
	if not player:
		return
	
	match level:
		1:
			damage = 8
			knockback_amount = 100
			attack_size = 1.0 * (1 + player.spell_size)
			rotation_speed = 3.0
			radius = 60.0
		2:
			damage = 8
			knockback_amount = 100
			attack_size = 1.0 * (1 + player.spell_size)
			rotation_speed = 3.5
			radius = 60.0
		3:
			damage = 12
			knockback_amount = 120
			attack_size = 1.2 * (1 + player.spell_size)
			rotation_speed = 4.0
			radius = 70.0
		4:
			damage = 12
			knockback_amount = 120
			attack_size = 1.2 * (1 + player.spell_size)
			rotation_speed = 4.5
			radius = 80.0
	
	scale = Vector2(1.0, 1.0) * attack_size

func _physics_process(delta):
	if not player:
		return
	
	# Вращаем меч вокруг игрока
	angle += rotation_speed * delta
	if angle >= TAU:
		angle -= TAU
	
	# Вычисляем позицию на окружности с учётом начального угла
	var current_angle = angle + start_angle
	var offset = Vector2(cos(current_angle), sin(current_angle)) * radius
	global_position = player.global_position + offset
	
	# Вычисляем направление удара (от центра к мечу, для knockback)
	attack_angle = offset.normalized()
	
	# Поворачиваем меч по направлению движения
	rotation = current_angle + PI / 2
