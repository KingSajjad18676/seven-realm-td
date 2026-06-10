extends Node

var _warning_cooldown: float = 0.0
var _music_player: AudioStreamPlayer = null
var _sfx_players: Array[AudioStreamPlayer] = []
const SFX_POOL_SIZE := 8
var _tone_cache: Dictionary = {}


func _ready() -> void:
	_ensure_audio_buses()
	_music_player = AudioStreamPlayer.new()
	_music_player.name = "MusicPlayer"
	_music_player.bus = "Music"
	add_child(_music_player)
	for i in SFX_POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.name = "SfxPlayer%d" % i
		p.bus = "SFX"
		add_child(p)
		_sfx_players.append(p)
	_apply_volume_from_settings()
	_start_menu_music()


func play_sfx(sfx_id: String) -> void:
	if sfx_id == "":
		return
	var stream := _get_tone(sfx_id)
	if stream == null:
		return
	for p in _sfx_players:
		if not p.playing:
			p.stream = stream
			p.play()
			return
	_sfx_players[0].stream = stream
	_sfx_players[0].play()


func play_warning() -> void:
	if _warning_cooldown > 0.0:
		return
	_warning_cooldown = 1.5
	play_sfx("warning")


func _start_menu_music() -> void:
	if _music_player == null:
		return
	_music_player.stream = _get_tone("menu_loop", 220.0, 0.35, 1.2)
	if _music_player.stream:
		_music_player.play()


func _apply_volume_from_settings() -> void:
	if SettingsService == null:
		return
	var music_db := linear_to_db(clampf(SettingsService.music_volume, 0.0, 1.0))
	var sfx_db := linear_to_db(clampf(SettingsService.sfx_volume, 0.0, 1.0))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), 0.0)
	var music_idx := AudioServer.get_bus_index("Music")
	if music_idx >= 0:
		AudioServer.set_bus_volume_db(music_idx, music_db)
	var sfx_idx := AudioServer.get_bus_index("SFX")
	if sfx_idx >= 0:
		AudioServer.set_bus_volume_db(sfx_idx, sfx_db)


func apply_settings_volumes() -> void:
	_apply_volume_from_settings()


func _get_tone(sfx_id: String, freq: float = 440.0, duration: float = 0.08, volume: float = 0.5) -> AudioStreamWAV:
	if _tone_cache.has(sfx_id):
		return _tone_cache[sfx_id]
	match sfx_id:
		"hero_attack":
			freq = 320.0
			duration = 0.06
		"hero_heavy":
			freq = 180.0
			duration = 0.14
		"hero_dodge":
			freq = 520.0
			duration = 0.05
		"hero_skill":
			freq = 280.0
			duration = 0.12
		"tether":
			freq = 400.0
			duration = 0.1
		"warning":
			freq = 880.0
			duration = 0.15
		"build":
			freq = 260.0
			duration = 0.07
		"victory":
			freq = 660.0
			duration = 0.25
		"defeat":
			freq = 140.0
			duration = 0.3
		"menu_loop":
			freq = 220.0
			duration = 1.2
			volume = 0.35
	var sample_rate := 22050
	var sample_count := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	for i in sample_count:
		var t := float(i) / float(sample_rate)
		var env := 1.0 - (float(i) / float(sample_count))
		var sample := sin(TAU * freq * t) * volume * env
		var s16 := int(clampf(sample * 32767.0, -32768.0, 32767.0))
		data[i * 2] = s16 & 0xFF
		data[i * 2 + 1] = (s16 >> 8) & 0xFF
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	wav.data = data
	if sfx_id == "menu_loop":
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	_tone_cache[sfx_id] = wav
	return wav


func _process(delta: float) -> void:
	if _warning_cooldown > 0.0:
		_warning_cooldown = maxf(0.0, _warning_cooldown - delta)


func _ensure_audio_buses() -> void:
	if AudioServer.get_bus_index("Music") < 0:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, "Music")
	if AudioServer.get_bus_index("SFX") < 0:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, "SFX")
