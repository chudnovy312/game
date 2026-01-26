extends Control

# Главное меню с Web3 интеграцией
var level = "res://World/world.tscn"
var start_upgrade := "icespear1"

@onready var connect_panel = $ConnectPanel
@onready var main_menu_panel = $MainMenuPanel
@onready var btn_connect = $ConnectPanel/btn_connect_wallet
@onready var btn_disconnect = $MainMenuPanel/btn_disconnect
@onready var lbl_wallet_address = $MainMenuPanel/lbl_wallet_address

func _ready():
	update_ui()
	# Подписываемся на сигналы кошелька
	WalletManager.wallet_connected.connect(_on_wallet_connected)
	WalletManager.wallet_disconnected.connect(_on_wallet_disconnected)

func update_ui():
	var is_connected = WalletManager.is_wallet_connected()
	
	if connect_panel:
		connect_panel.visible = not is_connected
	if main_menu_panel:
		main_menu_panel.visible = is_connected
	
	if is_connected and lbl_wallet_address:
		var address = WalletManager.get_wallet_address()
		if address.length() > 10:
			var short_address = address.substr(0, 6) + "..." + address.substr(address.length() - 4)
			lbl_wallet_address.text = "Wallet: " + short_address

func _on_btn_connect_wallet_click_end():
	# Заглушка для подключения кошелька
	# В реальной реализации здесь будет вызов JavaScript для MetaMask/WalletConnect
	# Пока используем тестовый адрес
	var test_address = "0x" + "".join(Array(range(40)).map(func(i): return str(randi() % 16).hex()))
	WalletManager.connect_wallet(test_address)

func _on_btn_disconnect_click_end():
	WalletManager.disconnect_wallet()

func _on_wallet_connected(address: String):
	update_ui()

func _on_wallet_disconnected():
	update_ui()

# Основное меню
func _on_btn_start_game_click_end():
	get_tree().set_meta("start_upgrade", start_upgrade)
	get_tree().change_scene_to_file(level)

func _on_btn_castle_click_end():
	get_tree().change_scene_to_file("res://TitleScreen/coming_soon.tscn")

func _on_btn_market_click_end():
	get_tree().change_scene_to_file("res://TitleScreen/coming_soon.tscn")

func _on_btn_arena_click_end():
	get_tree().change_scene_to_file("res://TitleScreen/coming_soon.tscn")

func _on_btn_tavern_click_end():
	get_tree().change_scene_to_file("res://TitleScreen/coming_soon.tscn")

func _on_btn_leaderboard_click_end():
	get_tree().change_scene_to_file("res://TitleScreen/leaderboard.tscn")

func _on_btn_exit_click_end():
	get_tree().quit()

# Выбор стартового оружия
func _on_btn_start_icespear_click_end():
	start_upgrade = "icespear1"

func _on_btn_start_tornado_click_end():
	start_upgrade = "tornado1"

func _on_btn_start_javelin_click_end():
	start_upgrade = "javelin1"
