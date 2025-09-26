# Scrapstronaut Part 2 Description
The second iteration of this game introduces a new enemy called the UFO.
This enemy's behavior is made entirely using an GDextension node.

Otherwise, the gameplay loop remains the same. Collect as much scrap as possible and avoid the obstacles!

## IMPORTANT
Edits were made to the SCONS file that allows the bin to be made within the necessary files. I'm not sure how this code will function without the SCONS file I have here so if something goes wrong please let me know. My email is tsj78@nau.edu.

## Behavior
This enemy will spawn once every few seconds and will continuously chase the player until it expires after a certain period of time.
In order to properly rotate and chase the player, the process function will continuously calculate the target position and rotation and adjust it's own direction in return.

After the timer expires or the player hits the ufo, signals on_hit for player collisions and destroy_ufo for timer expiration will be emitted to handle the destruction of the ufo. Player collisions act as a signal that trigggers the ufo's on_hit method whereas the timer expiration will sends out the destruction signal to update the score accordingly.

## Inspector Edits
With the inspector, the turn rate and speed of the ufo can be changed. This will affect how quickly the ufo is able to re-orient itself towards the player and how fast it travels.

## How Does Collision Work?
As a Sprite2D node, the ufo does not have innate collision with the player. This is resolved by adding an Area2D node as a child of the ufo to allow for collisions.
