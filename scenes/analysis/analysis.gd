extends Node2D

var udp = PacketPeerUDP.new()

var target_IP = "127.0.0.1"
var target_port = 16384

var relay_pid : int = -1

var flag_result : String

@onready var mainROM = $"../mainROM"

func _ready():
	var relay_path = ProjectSettings.globalize_path("res://scenes/analysis/relay.exe")
	relay_pid = OS.create_process(relay_path, [])
	udp.set_dest_address(target_IP, target_port)

	if mainROM:
		mainROM.flag.connect(_on_flaged)
		mainROM.prized.connect(_on_prized)

func _on_flaged(result_flag):
	flag_result = result_flag

func _on_prized(_reel_result):
	send_udp_data(flag_result)


func send_udp_data(data):
	var packet = data.to_utf8_buffer()
	udp.put_packet(packet)

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_PREDELETE:
		if relay_pid != -1:
			OS.kill(relay_pid)
