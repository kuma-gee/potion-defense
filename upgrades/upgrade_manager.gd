extends Node

const PATH = "res://upgrades/"

var upgrades: Dictionary[String, UpgradeResource] = {}
var upgrade_levels: Dictionary[int, Array] = {}

var player_upgrades: Array[String] = []

func _ready() -> void:
    var dir = DirAccess.open(PATH)
    if dir == null:
        push_error("Failed to open upgrades directory")
        return

    dir.list_dir_begin()
    var file_name = dir.get_next()
    while file_name != "":
        if file_name.ends_with(".tres"):
            var upgrade_res = ResourceLoader.load(PATH + file_name) as UpgradeResource
            if upgrade_res != null:
                upgrades[upgrade_res.name] = upgrade_res
                if not upgrade_levels.has(upgrade_res.from_level):
                    upgrade_levels[upgrade_res.from_level] = []
                upgrade_levels[upgrade_res.from_level].append(upgrade_res.name)
            else:
                push_warning("Failed to load upgrade resource: %s" % file_name)
        file_name = dir.get_next()
    dir.list_dir_end()

func add_player_upgrade(upgrade_name: String) -> void:
    if upgrade_name in upgrades and upgrade_name not in player_upgrades:
        player_upgrades.append(upgrade_name)

func get_upgrades_for_level(level: int) -> Array:
    var available = []

    while level > 0:
        if upgrade_levels.has(level):
            for up in upgrade_levels[level]:
                if up not in player_upgrades and up not in available:
                    available.append(up)
        level -= 1

    return available

func get_upgrade_resource(upgrade_name: String) -> UpgradeResource:
    return upgrades.get(upgrade_name, null)