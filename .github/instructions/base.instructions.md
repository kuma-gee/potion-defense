---
applyTo: '**'
---

## Coding Guidelines

- Do not add comments that explain what the code does; instead, write self-explanatory code
- Prefer composition over inheritance wherever possible
- Use type hints for all variables and function parameters
- Always add a class name for scripts if it's not autoloaded

## Godot Guidelines

- Follow Godot's node naming conventions (PascalCase for nodes, snake_case for methods)
- Use @onready annotations to access direct child nodes
- Use @export annotations for nodes that are not direct children
- Use signals for loose coupling between nodes
- Always connect signals in code
- Utilize typed signals to improve safety and IDE assistance (e.g., signal item_collected(item_name: String))
- Always add a constant variable for group names at the top of the class so it can be reused

## TileMap Implementation

- TileMap node is deprecated - use multiple TileMapLayer nodes instead
- Convert existing TileMaps using the TileMap bottom panel toolbox option "Extract TileMap layers"
- Access TileMap layers through TileMapLayer nodes
- Update navigation code to use TileMapLayer.get_navigation_map()
- Store layer-specific properties on individual TileMapLayer nodes