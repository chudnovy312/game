extends Node

# Singleton для управления кошельком
var wallet_address = ""
var is_connected = false

signal wallet_connected(address)
signal wallet_disconnected()

func connect_wallet(address: String):
	wallet_address = address
	is_connected = true
	emit_signal("wallet_connected", address)
	get_tree().set_meta("wallet_address", address)

func disconnect_wallet():
	wallet_address = ""
	is_connected = false
	emit_signal("wallet_disconnected")
	if get_tree().has_meta("wallet_address"):
		get_tree().remove_meta("wallet_address")

func get_wallet_address() -> String:
	return wallet_address

func is_wallet_connected() -> bool:
	return is_connected
