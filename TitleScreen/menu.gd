extends Control

# Главное меню с Web3 интеграцией
var level = "res://World/world.tscn"
var start_upgrade := "icespear1"

@onready var connect_panel = get_node_or_null("ConnectPanel")
@onready var main_menu_panel = get_node_or_null("MainMenuPanel")
@onready var btn_connect = get_node_or_null("ConnectPanel/btn_connect_wallet")
@onready var btn_disconnect = get_node_or_null("MainMenuPanel/btn_disconnect")
@onready var lbl_wallet_address = get_node_or_null("MainMenuPanel/lbl_wallet_address")

func _ready():
	# Подписываемся на сигналы кошелька
	if WalletManager:
		WalletManager.wallet_connected.connect(_on_wallet_connected)
		WalletManager.wallet_disconnected.connect(_on_wallet_disconnected)
		# Автоматически подключаем тестовый кошелёк для удобства тестирования
		if not WalletManager.is_wallet_connected():
			var hex_chars = "0123456789abcdef"
			var test_address = "0x"
			for i in range(40):
				test_address += hex_chars[randi() % 16]
			WalletManager.connect_wallet(test_address)
	
	update_ui()

func update_ui():
	# Если WalletManager не загружен, показываем меню сразу (для тестирования)
	var wallet_connected = false
	if WalletManager:
		wallet_connected = WalletManager.is_wallet_connected()
	
	# Если панели не найдены, значит это старое меню - показываем всё
	if not connect_panel and not main_menu_panel:
		return
	
	if connect_panel:
		connect_panel.visible = not wallet_connected
	if main_menu_panel:
		main_menu_panel.visible = wallet_connected
	
	if wallet_connected and lbl_wallet_address:
		var address = WalletManager.get_wallet_address()
		if address.length() > 10:
			var short_address = address.substr(0, 6) + "..." + address.substr(address.length() - 4)
			lbl_wallet_address.text = "Wallet: " + short_address

func _on_btn_connect_wallet_click_end():
	# Заглушка для подключения кошелька
	# В реальной реализации здесь будет вызов JavaScript для MetaMask/WalletConnect
	# Пока используем тестовый адрес
	var hex_chars = "0123456789abcdef"
	var test_address = "0x"
	for i in range(40):
		test_address += hex_chars[randi() % 16]
	
	if WalletManager:
		WalletManager.connect_wallet(test_address)

func _on_btn_disconnect_click_end():
	if WalletManager:
		WalletManager.disconnect_wallet()

func _on_wallet_connected(_address: String):
	update_ui()

func _on_wallet_disconnected():
	update_ui()

func _on_btn_play_click_end():
	get_tree().set_meta("start_upgrade", start_upgrade)
	get_tree().change_scene_to_file(level)

func _on_btn_exit_click_end():
	get_tree().quit()

func _on_btn_start_icespear_click_end():
	start_upgrade = "icespear1"

func _on_btn_start_tornado_click_end():
	start_upgrade = "tornado1"

func _on_btn_start_javelin_click_end():
	start_upgrade = "javelin1"

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
