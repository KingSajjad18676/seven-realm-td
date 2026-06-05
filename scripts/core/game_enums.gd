class_name GameEnums
extends RefCounted

enum BattleState {
	PRE_BATTLE,
	WAVE_ACTIVE,
	PAUSED,
	VICTORY,
	DEFEAT,
}

enum RegionLightState {
	STABLE,
	PRESSURED,
	CRITICAL,
	COLLAPSED,
}

enum TowerFamily {
	ARCHER,
	SACRED_FIRE,
	HEAVY,
	CONTROL,
	FORGE,
}

enum DamageType {
	PHYSICAL,
	FIRE,
	MAGIC,
}

enum TargetMode {
	FIRST,
	LAST,
	STRONGEST,
}

enum EnemyTag {
	GRUNT,
	RUNNER,
	BRUTE,
	CORRUPTOR,
	BOSS,
}

enum HijackPhase {
	NONE,
	WARNING,
	HIJACKED,
	RECOVERING,
}
