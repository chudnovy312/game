extends Area2D

# Стрела гоблина-лучника
var speed = 150.0
var damage = 2
var target = Vector2.ZERO
var angle = Vector2.ZERO

@onready var player = get_tree().get_first_node_in_group("player")

func _ready():
	if target != Vector2.ZERO:
		angle = global_position.direction_to(target)
		rotation = angle.angle() + PI / 2
	else:
		queue_free()
	
	# Удаляемся через 3 секунды, если не попали
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 3.0
	timer.one_shot = true
	timer.timeout.connect(queue_free)
	timer.start()

func _physics_process(delta):
	global_position += angle * speed * delta
	
	# Проверяем столкновение с игроком через расстояние
	if player:
		var distance = global_position.distance_to(player.global_position)
		if distance < 20.0:
			if player.has_method("_on_hurt_box_hurt"):
				player._on_hurt_box_hurt(damage, angle, 50)
			queue_free()

func _on_area_entered(_area):
	# Проверяем попадание в HurtBox игрока через расстояние в _physics_process
	# Эта функция оставлена для совместимости, но не используется
	pass
