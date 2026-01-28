extends Area2D

var level = 1
var hp = 1
var speed = 130  # Увеличено на 30% (было 100)
var min_damage = 4
var max_damage = 6
var damage = 5  # Используется для расчета, но реальный урон будет случайным
var knockback_amount = 100
var attack_size = 1.0
@export var crit_chance: float = 0.10  # 10% шанс крита
@export var crit_multiplier: float = 2.0  # x2 урон при крите
var is_critical: bool = false

var target = Vector2.ZERO
var angle = Vector2.ZERO

@onready var player = get_tree().get_first_node_in_group("player")
signal remove_from_array(object)

func _ready():
	angle = global_position.direction_to(target)
	rotation = angle.angle() + deg_to_rad(135)
	match level:
		1:
			hp = 1
			speed = 130  # Увеличено на 30%
			min_damage = 4
			max_damage = 6
			damage = 5
			knockback_amount = 100
			attack_size = 1.0 * (1 + player.spell_size)
		2:
			hp = 1
			speed = 130  # Увеличено на 30%
			min_damage = 4
			max_damage = 6
			damage = 5
			knockback_amount = 100
			attack_size = 1.0 * (1 + player.spell_size)
		3:
			hp = 2
			speed = 130  # Увеличено на 30%
			min_damage = 7
			max_damage = 9
			damage = 8
			knockback_amount = 100
			attack_size = 1.0 * (1 + player.spell_size)
		4:
			hp = 2
			speed = 130  # Увеличено на 30%
			min_damage = 7
			max_damage = 9
			damage = 8
			knockback_amount = 100
			attack_size = 1.0 * (1 + player.spell_size)
	
	# Вычисляем случайный урон и проверяем крит
	calculate_damage()

	
	var tween = create_tween()
	tween.tween_property(self,"scale",Vector2(1,1)*attack_size,1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()

func calculate_damage():
	# Случайный урон в диапазоне
	damage = randi_range(min_damage, max_damage)
	# Проверка на критический удар
	is_critical = randf() < crit_chance
	if is_critical:
		damage = int(damage * crit_multiplier)

func _physics_process(delta):
	position += angle*speed*delta

func enemy_hit(charge = 1):
	hp -= charge
	if hp <= 0:
		emit_signal("remove_from_array",self)
		queue_free()


func _on_timer_timeout():
	emit_signal("remove_from_array",self)
	queue_free()
