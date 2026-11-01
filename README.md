# Roblox 2D Game

An experimental attempt to build a 2D RPG inside Roblox, a platform primarily designed around 3D experiences.

Inspired by games like Prodigy, the project recreates a traditional 2D RPG environment using Roblox GUI elements instead of the standard 3D world. The player explores tile-based maps, interacts with NPCs, encounters creatures, and participates in turn-based battles.

## Building a 2D Game in Roblox

Roblox is fundamentally a 3D engine, so creating a 2D game required a different approach to rendering.

I built the game world using arrays of GUI elements, with each tile and character represented by an image rather than a physical object. The normal Roblox character and its 3D appearance are hidden, leaving the GUI to function as the game's visual environment.

This approach allowed me to build a 2D game framework using Roblox's existing interface and scripting systems.

## Features

### Tile-Based World

The game uses numerical tilemaps to define its environments.

- **Grid-Based Maps:** Maps are represented as arrays, with each number corresponding to a tile type.
- **Tile Properties:** Tile definitions control appearance, walkability, and rendering order.
- **Multiple Layers:** Overlay tiles can be rendered above the base map.
- **Collision:** Player movement checks tile walkability before allowing movement.
- **Map Transitions:** Special tiles can transport the player between maps, with screen-fade transitions.

The current project includes two maps: PlayerHouse and VelocityHills.

### Player Movement and Animation

The player moves through the map using WASD or the arrow keys.

- Tile-based collision detection.
- Camera tracking that keeps the player centered.
- Directional animations for north, south, east, and west.
- Frame-based sprite animation.

### NPCs and Dialogue

NPCs are defined through map data and spawned into the game world.

Players can approach NPCs and interact with them using E. Dialogue is displayed through a separate interface with character portraits and a typewriter effect.

Dialogue can be advanced using E, Space, or Enter. Pressing an advance key while text is appearing immediately finishes the current line.

### Creature Encounters

Creatures are spawned at predefined map positions and have individual statistics, including:

- Health and maximum health.
- Attack and defense.
- Speed.
- Available moves.
- Maximum energy.

Colliding with a creature triggers a battle encounter.

### Turn-Based Battles

The battle system is inspired by Pokémon-style combat.

Each battle has a player-controlled creature and an enemy creature. Turn order is determined by their respective speed stats.

Attacks use several properties:

- **Power:** Determines the move's base damage.
- **Accuracy:** Determines the chance of successfully hitting.
- **Energy Cost:** Determines how much energy an attack consumes.

Damage is calculated using the attacker's attack stat and the defender's defense stat, with a small random variation.

Enemies select randomly from their available moves.

**Current limitation:** Battles currently take place entirely through Roblox's chat and console output. Players enter commands through chat, while battle messages and status information are printed to the console. The exploration and NPC interfaces are GUI-based, but the battle interface has not yet been implemented.

### Energy and Physics Questions

Using attacks consumes energy, creating a resource that must be managed during battles.

To recover energy, the player can choose to rest. This generates a random kinematics question covering topics such as acceleration, velocity, and displacement.

Answering correctly restores 10 energy. Numerical answers allow a small tolerance for rounding differences.

The player's remaining energy is preserved between encounters.

## Development

This project was an experiment in adapting Roblox's 3D-oriented systems to a 2D game.

Instead of relying on Roblox's normal character movement and world rendering, I built separate systems for map rendering, movement, collision, animations, NPC interactions, and creature encounters.

The result is a collection of interconnected systems that recreates several conventions of a traditional 2D RPG within an environment not originally designed for one.
