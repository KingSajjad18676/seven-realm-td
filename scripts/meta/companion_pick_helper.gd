class_name CompanionPickHelper
extends RefCounted

const SHRINE_COMPANION_IDS: Array[String] = [
	"companion_royal_cheetah",
	"companion_simurgh_fledgling",
	"companion_zavareh",
]


static func pick_pool(active_companion_id: String, count: int = 3) -> Array[CompanionData]:
	if active_companion_id != "":
		return []
	var pool: Array[CompanionData] = []
	for companion_id in SHRINE_COMPANION_IDS:
		var data := ContentRegistry.get_companion(companion_id) if ContentRegistry else null
		if data == null:
			for fallback in ContentCatalog.build_companions():
				if fallback.companion_id == companion_id:
					data = fallback
					break
		if data:
			pool.append(data)
	pool.shuffle()
	var picks: Array[CompanionData] = []
	for i in range(mini(count, pool.size())):
		picks.append(pool[i])
	return picks
