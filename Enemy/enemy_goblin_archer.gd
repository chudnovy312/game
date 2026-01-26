extends CharacterBody2D

# Гоблин-лучник - дальнобойный враг
@export var movement_speed = 22.0  # Медленнее обычного
@export var hp = 15
@export var knockback_recovery = 3.0
@export var experience = 2
@export var enemy_damage = 2
@export var attack_range = 200.0  # Дистанция атаки
@export var attack_cooldown = 2.0  # Перезарядка атаки

var knockback = Vector2.ZERO
var attack_timer = 0.0
var arrow_scene = preload("res://Enemy/arrow_projectile.tscn")

@onready var player = get_tree().get_first_node_in_group("player")
@onready var loot_base = get_tree().get_first_node_in_group("loot")
@onready var sprite = $Sprite2D
@onready var anim = $AnimationPlayer
@onready var snd_hit = $snd_hit
@onready var hitBox = $HitBox

var death_anim = preload("res://Enemy/explosion.tscn")
var exp_gem = preload("res://Objects/experience_gem.tscn")

signal remove_from_array(object)

func _ready():
	add_to_group("enemy")
	anim.play("walk")
	hitBox.damage = enemy_damage

func _physics_process(delta):
	# Убеждаемся, что knockback всегда Vector2
	if knockback is Vector2:
		knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)
	else:
		knockback = Vector2.ZERO
	
	if not player:
		return
	
	var direction = global_position.direction_to(player.global_position)
	var distance_to_player = global_position.distance_to(player.global_position)
	
	# Если далеко от игрока - приближаемся, если близко - отступаем и стреляем
	if distance_to_player > attack_range:
		velocity = direction * movement_speed
	else:
		# Отступаем от игрока
		velocity = -direction * movement_speed * 0.5
	
	velocity += knockback
	move_and_slide()
	
	# Атакуем, если в радиусе и прошла перезарядка
	attack_timer += delta
	if distance_to_player <= attack_range and attack_timer >= attack_cooldown:
		shoot_arrow()
		attack_timer = 0.0
	
	if direction.x > 0.1:
		sprite.flip_h = true
	elif direction.x < -0.1:
		sprite.flip_h = false

func shoot_arrow():
	if not player:
		return
	
	var arrow = arrow_scene.instantiate()
	arrow.global_position = global_position
	arrow.target = player.global_position
	arrow.damage = enemy_damage
	get_parent().add_child(arrow)

func death():
	emit_signal("remove_from_array", self)
	var enemy_death = death_anim.instantiate()
	enemy_death.scale = sprite.scale
	enemy_death.global_position = global_position
	get_parent().call_deferred("add_child", enemy_death)
	var new_gem = exp_gem.instantiate()
	new_gem.global_position = global_position
	var exp_given = experience
	if player:
		var level_penalty = max(0.7, 1.0 - (player.experience_level - 20) * 0.01)
		exp_given = int(experience * level_penalty)
	new_gem.experience = exp_given
	loot_base.call_deferred("add_child", new_gem)
	queue_free()

func _on_hurt_box_hurt(damage, angle, knockback_amount):
	var damage_pos = global_position
	if sprite:
		var sprite_rect = sprite.get_rect()
		damage_pos.y -= sprite_rect.size.y * sprite.scale.y / 2
	
	var damage_type = "normal"
	if DamageNumberManager:
		DamageNumberManager.show_damage(damage, damage_pos, false, damage_type)
	
	hp -= damage
	if angle is Vector2 and angle.length() > 0:
		knockback = angle * knockback_amount
	else:
		knockback = global_position.direction_to(player.global_position) * knockback_amount
	if hp <= 0:
		death()
	else:
		snd_hit.play()
