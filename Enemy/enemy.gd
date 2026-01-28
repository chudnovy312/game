extends CharacterBody2D


@export var base_movement_speed = 26.0  # Базовая скорость (увеличено на 30% от 20.0)
@export var movement_speed = 26.0  # Текущая скорость с модификаторами
@export var hp = 10
@export var knockback_recovery = 3.5
@export var experience = 1
@export var enemy_damage = 1
var knockback = Vector2.ZERO

@onready var player = get_tree().get_first_node_in_group("player")
@onready var loot_base = get_tree().get_first_node_in_group("loot")
@onready var sprite = $Sprite2D
@onready var anim = $AnimationPlayer
@onready var snd_hit = $snd_hit
@onready var hitBox = $HitBox

var death_anim = preload("res://Enemy/explosion.tscn")
var exp_gem = preload("res://Objects/experience_gem.tscn")
var healing_potion = preload("res://Objects/healing_potion.tscn")
var health_bar_scene = preload("res://Enemy/enemy_health_bar.tscn")
var damage_number_scene = preload("res://Utility/damage_number.tscn")

@export var healing_potion_drop_chance: float = 0.05  # 5% шанс выпадения зелья лечения

var max_hp: float = 10.0
var health_bar = null

signal remove_from_array(object)


func _ready():
	base_movement_speed = movement_speed  # Сохраняем базовую скорость
	max_hp = hp  # Сохраняем максимальное HP
	update_speed_from_modifier()
	anim.play("walk")
	hitBox.damage = enemy_damage
	# Создаем HP бар
	health_bar = health_bar_scene.instantiate()
	add_child(health_bar)
	update_health_bar()

func update_speed_from_modifier():
	movement_speed = base_movement_speed * (1.0 + PlayerData.enemy_speed_modifier)

func _physics_process(_delta):
	knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)
	var direction = global_position.direction_to(player.global_position)
	velocity = direction*movement_speed
	velocity += knockback
	move_and_slide()
	
	if direction.x > 0.1:
		sprite.flip_h = true
	elif direction.x < -0.1:
		sprite.flip_h = false

func death():
	emit_signal("remove_from_array",self)
	var enemy_death = death_anim.instantiate()
	enemy_death.scale = sprite.scale
	enemy_death.global_position = global_position
	get_parent().call_deferred("add_child",enemy_death)
	var new_gem = exp_gem.instantiate()
	new_gem.global_position = global_position
	new_gem.experience = experience
	loot_base.call_deferred("add_child",new_gem)
	
	# Шанс выпадения зелья лечения
	if randf() < healing_potion_drop_chance:
		var new_potion = healing_potion.instantiate()
		new_potion.global_position = global_position
		loot_base.call_deferred("add_child",new_potion)
	
	# Удаляем HP бар
	if health_bar != null:
		health_bar.queue_free()
	
	queue_free()

func _on_hurt_box_hurt(damage, angle, knockback_amount, is_critical = false):
	hp -= damage
	knockback = angle * knockback_amount
	update_health_bar()
	
	# Создаем вылетающую цифру урона
	spawn_damage_number(damage, is_critical)
	
	if hp <= 0:
		death()
	else:
		snd_hit.play()

func spawn_damage_number(damage_value: int, is_crit: bool = false):
	var damage_num = damage_number_scene.instantiate()
	damage_num.damage_value = damage_value
	damage_num.is_critical = is_crit
	damage_num.global_position = global_position + Vector2(0, -15)  # Немного выше врага
	get_tree().current_scene.add_child(damage_num)

func update_health_bar():
	if health_bar != null:
		health_bar.update_health(hp, max_hp)
