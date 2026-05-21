# Third person controller template

## What this project contains
This project contains foundations to build a TPS game:
- a CharacterBody3D player controller
- a RigidBody3D player controller
- an autoload InputMap that will add the inputs when loaded
- a template mesh with animations
- a template level

## How to use
1. Add the tps_input_map.gd to the autoloaded scripts in your project
2. Create a new scene from Node3D, drop the Template Level scene and add a player controller to the Node3D
3. Add a pawn to the player controller
4. Assign the pawn to the pawn variable in the inspector of the player controller
