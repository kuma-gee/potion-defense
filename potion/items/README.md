# Pickupable Item System

A flexible pickup system for the magical arena game that allows items to be spawned as physical RigidBody3D objects with automatic visual representation.

## 📦 Components

### `Pickupable` Class
- Extends `RigidBody3D`
- Automatically creates visual representation based on item type
- Supports auto-pickup when player enters pickup radius
- Emits signals when picked up

### `ItemResource` Updates
- Added `ITEM_SCENES` dictionary mapping item types to visual scenes
- Added `get_item_scene()` static method to retrieve scenes by type

## 🎮 Usage

### Basic Spawning

```gdscript
# Spawn a pickupable item
var pickupable_scene = preload("res://potion/items/pickupable.tscn")
var item = pickupable_scene.instantiate() as Pickupable

# Set the item type
item.item_type = ItemResource.Type.RED_HERB

# Position it
item.global_position = Vector3(0, 1, 0)

# Add to scene
get_tree().current_scene.add_child(item)
```

### Enable Auto-Pickup

```gdscript
item.auto_pickup = true  # Player picks up when getting close
```

### Manual Pickup

```gdscript
# From player or other actor
if pickupable_item.can_pickup():
    pickupable_item.pickup_by(self)
```

### Connect to Signals

```gdscript
item.picked_up.connect(func(item_type, actor):
    print("%s picked up %s" % [actor.name, ItemResource.build_name(item_type)])
)
```

### Drop Items (from FPSPlayer)

```gdscript
# Player drops held item by pressing 'G' key
# Item spawns in front of player with throw physics
```

## 🎨 Visual System

Each item type has its own visual scene located in `res://potion/items/scenes/`:

### Ingredients
- `red_herb.tscn` - Red cylindrical herbs
- `sulfur.tscn` - Yellow sphere
- `blue_crystal.tscn` - Blue crystal prism
- `water.tscn` - Transparent blue sphere
- `green_moss.tscn` - Green flat box
- `spider_venom.tscn` - Purple sphere
- `white_flower.tscn` - White sphere
- `spring_water.tscn` - Light blue transparent sphere

### Potions
- `potion_empty.tscn` - Empty glass bottle
- `potion_fire_bomb.tscn` - Bottle with red glowing liquid
- `potion_ice_shard.tscn` - Bottle with blue glowing liquid
- `potion_poison_cloud.tscn` - Bottle with green glowing liquid
- `potion_paralysis.tscn` - Bottle with white glowing liquid

## 🔧 Customization

### Replace Placeholder Visuals

To use custom 3D models:

1. Create your item scene (e.g., `my_custom_herb.tscn`)
2. Update `ItemResource.ITEM_SCENES`:
   ```gdscript
   const ITEM_SCENES = {
       Type.RED_HERB: preload("res://path/to/my_custom_herb.tscn"),
       # ...
   }
   ```

### Adjust Physics

In the pickupable scene or via code:
```gdscript
pickupable.mass = 1.0
pickupable.gravity_scale = 2.0
pickupable.linear_velocity = Vector3(0, 5, 0)  # Initial velocity
```

### Modify Pickup Radius

```gdscript
pickupable.pickup_radius = 2.0  # Default is 1.5
```

## 📝 Properties

### Pickupable Properties
- `item_type`: ItemResource.Type - The type of item
- `pickup_radius`: float - Distance at which auto-pickup triggers
- `auto_pickup`: bool - Enable/disable automatic pickup
- `is_picked_up`: bool - Read-only, whether item has been picked up

### Signals
- `picked_up(item_type: ItemResource.Type, by: Node3D)` - Emitted when picked up

## 🎯 Integration Points

### FPSPlayer Integration
- Drop items with 'G' key (`drop_item` action)
- Items spawn with throw physics
- Automatic pickup when walking near items

### Chest Integration
- Can spawn pickupable items when opened
- Replace direct inventory addition with physical drops

### Cauldron Integration
- Can produce pickupable potions
- Drop potions as physical objects

## ⚠️ Notes

- Item visual scenes are currently placeholder meshes
- Replace with actual 3D models for better visuals
- Collision layers: Pickupable uses layer 32, pickup area detects layer 2 (players)
- All items use physics and will bounce/roll realistically

## 🚀 Future Enhancements

- [ ] Add item glow/outline for better visibility
- [ ] Floating/bobbing animation
- [ ] Particle effects for rare items
- [ ] Sound effects on pickup
- [ ] Stack similar items together
- [ ] Inventory weight/space management
