extends Node

# Данные профиля игрока
var wallet_address: String = ""
var nickname: String = ""
var login_time: int = 0
var wallet_connected: bool = false  # Переименовано из is_connected, чтобы не конфликтовать с методом базового класса

# Модификаторы скорости
var enemy_speed_modifier: float = 0.0  # Модификатор скорости врагов (в процентах)

func connect_wallet(address: String):
	wallet_address = address
	# Создаем короткий адрес для никнейма (первые 6 символов + ... + последние 4)
	if address.length() > 10:
		nickname = address.substr(0, 6) + "..." + address.substr(address.length() - 4)
	else:
		nickname = address
	login_time = Time.get_unix_time_from_system()
	wallet_connected = true
	print("Wallet connected: ", address)

func disconnect_wallet():
	wallet_address = ""
	nickname = ""
	login_time = 0
	wallet_connected = false
	print("Wallet disconnected")

func get_wallet_address() -> String:
	return wallet_address

func is_wallet_connected() -> bool:
	return wallet_connected
