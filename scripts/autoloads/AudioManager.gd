extends Node
## Manages all audio playback with separate volume buses for master, music, and SFX.

const BUS_MASTER := "Master"
const BUS_MUSIC := "Music"
const BUS_SFX := "SFX"

@onready var _music_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var _sfx_pool: Array[AudioStreamPlayer] = []

const SFX_POOL_SIZE := 8


func _ready() -> void:
	add_child(_music_player)
	_music_player.bus = BUS_MUSIC
	for i in SFX_POOL_SIZE:
		var sfx := AudioStreamPlayer.new()
		sfx.bus = BUS_SFX
		add_child(sfx)
		_sfx_pool.append(sfx)


func play_music(stream: AudioStream, fade_in: float = 1.0) -> void:
	if _music_player.stream == stream:
		return
	if fade_in > 0.0:
		var tween := create_tween()
		tween.tween_property(_music_player, "volume_db", -80.0, fade_in * 0.5)
		tween.tween_callback(func():
			_music_player.stream = stream
			_music_player.play()
			var fade_tween := create_tween()
			fade_tween.tween_property(_music_player, "volume_db", 0.0, fade_in * 0.5)
		)
	else:
		_music_player.stream = stream
		_music_player.play()


func stop_music(fade_out: float = 1.0) -> void:
	if fade_out > 0.0:
		var tween := create_tween()
		tween.tween_property(_music_player, "volume_db", -80.0, fade_out)
		tween.tween_callback(_music_player.stop)
	else:
		_music_player.stop()


func play_sfx(stream: AudioStream, volume_db: float = 0.0, pitch_scale: float = 1.0) -> void:
	var player := _get_free_sfx_player()
	if not player:
		return
	player.stream = stream
	player.volume_db = volume_db
	player.pitch_scale = pitch_scale
	player.play()


func _get_free_sfx_player() -> AudioStreamPlayer:
	for p in _sfx_pool:
		if not p.playing:
			return p
	return _sfx_pool[0]


func set_volume(bus_name: String, linear_volume: float) -> void:
	var bus_idx := AudioServer.get_bus_index(bus_name)
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(clampf(linear_volume, 0.0, 1.0)))


func get_volume(bus_name: String) -> float:
	var bus_idx := AudioServer.get_bus_index(bus_name)
	if bus_idx >= 0:
		return db_to_linear(AudioServer.get_bus_volume_db(bus_idx))
	return 1.0
