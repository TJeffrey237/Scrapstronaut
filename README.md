# Scrapstronaut Part 3 Description
The third iteration of this game introduces a visual flocking effect for coin collection. The player is unable to interact with these directly because they are used purely for visual effect.

## Behavior
Whenever a coin is collected, a flock of boids spawn at the player's position and head for the score counter. They will then dissapear once their target is reached.

To accomplish this, there are Boid, BoidSpawner, and Boid Target nodes. The Boid node holds the script for calculating all the flocking properties such as separation, follow speed, setting target, collision, etc. The BoidSpawner node is only spawned and activated after the collect signal is activayed, in which the specified number of Boids will be spawned at that position and begin heading towards the set target. In terms of the target, it is just a static instance in front of the score label that the player cannot see and is part of it's own group so that different targets may be defined in the event that I want different scenes of gameplay.

## Inspector Edits
Inside the inspecctor, you can edit a lot of Boid properties that will affect their behavior such as speed and weights. You can also change the number of Boids you want to be spawned within the BoidSpawner node.
