extends Area2D

# Объект ключа, который падает с боссов
var target = null
var speed = -1

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var sound = $snd_collected

func _ready():
	# Можно добавить анимацию вращения или свечения
	pass

func _physics_process(delta):
	if target != null:
		global_position = global_position.move_toward(target.global_position, speed)
		speed += 2*delta

# Ключ использует ту же систему сбора, что и гемы опыта
# GrabArea и CollectArea игрока автоматически обработают ключ

func collect():
	sound.play()
	collision.call_deferred("set","disabled",true)
	sprite.visible = false
	return 1  # Возвращает 1 ключ

func _on_snd_collected_finished():
	queue_free()
