using Godot;
using System.Collections.Generic;

public partial class Boid : CharacterBody2D
{
	[ExportGroup("Flocking Weights")]
	[Export] public float SeparationWeight = 1.8f;
	[Export] public float AlignmentWeight = 1.2f;
	[Export] public float CohesionWeight = 0.5f;
	[Export] public float FollowWeight = 2.0f;

	[ExportGroup("Boid Properties")]
	[Export] public float MaxSpeed = 500.0f;
	// How quickly the boid can change direction
	[Export] public float SteeringSpeed = 6.0f;
	[Export] public float SeparationDistance = 75.0f;
	[Export] public float FollowRadius = 300.0f;
	
	private List<Boid> _neighbors = new();
	private Area2D _detectionArea;
	private CharacterBody2D _target;
	
	public override void _Ready()
	{
		_detectionArea = GetNode<Area2D>("DetectionArea");
		_detectionArea.BodyEntered += OnBodyEntered;
		_detectionArea.BodyExited += OnBodyExited;
		
		var randomAngle = GD.Randf() * Mathf.Pi * 2;
		var randomVelocity = new Vector2(Mathf.Cos(randomAngle), Mathf.Sin(randomAngle)) * MaxSpeed;
		Velocity = randomVelocity;
		MoveAndSlide();
		
		// Optional: Make boid face its direction of movement
		LookAt(Position + Velocity);
	}
	public void SetTarget(CharacterBody2D Target)
	{
		_target = Target;
	}

	public override void _PhysicsProcess(double delta)
	{
		Vector2 steeringForce = Vector2.Zero;

		// Calculate the weighted sum of all steering behaviors
		steeringForce += Separation() * SeparationWeight;
		steeringForce += Alignment() * AlignmentWeight;
		steeringForce += Cohesion() * CohesionWeight;
		steeringForce += FollowTarget() * FollowWeight;

		// If there is a steering force, calculate the desired velocity
		if (steeringForce.LengthSquared() > 0)
		{
			Vector2 desiredVelocity = steeringForce.Normalized() * MaxSpeed;

			// Smoothly interpolate from the current velocity to the desired velocity.
			// Multiplying delta by SteeringSpeed makes the turn rate frame-rate independent and adjustable.
			Velocity = Velocity.Lerp(desiredVelocity, (float)delta * SteeringSpeed);
		}
		
		// Ensure velocity doesn't exceed max speed (good safety measure)
		Velocity = Velocity.LimitLength(MaxSpeed);

		MoveAndSlide();
		for (int i = 0; i < GetSlideCollisionCount(); i++)
		{
			var collision = GetSlideCollision(i);
			if (collision != null)
			{
				// Check if the node we collided with is our target
				if (collision.GetCollider() == _target)
				{
					// If it is, queue the boid for deletion and stop processing
					QueueFree();
					return; // Exit the function early since we're being deleted
				}
			}
		}
		// Make the boid face its direction of movement, only if it's actually moving.
		if (Velocity.LengthSquared() > 0)
		{
			Rotation = Velocity.Angle();
		}
	}

	private void OnBodyEntered(Node2D body)
	{
		if (body is Boid boid && body != this)
		{
			_neighbors.Add(boid);
		}
	}

	private void OnBodyExited(Node2D body)
	{
		if (body is Boid boid && body != this)
		{
			_neighbors.Remove(boid);
		}
	}

	private Vector2 Separation()
	{
		if (_neighbors.Count == 0) return Vector2.Zero;

		Vector2 steer = Vector2.Zero;
		int count = 0;
		foreach (var neighbor in _neighbors)
		{
			float distance = Position.DistanceTo(neighbor.Position);
			if (distance > 0 && distance < SeparationDistance)
			{
				// Calculate a vector pointing away from the neighbor,
				// and make it stronger the closer the neighbor is.
				Vector2 diff = (Position - neighbor.Position).Normalized();
				steer += diff / distance;
				count++;
			}
		}

		if (count > 0)
		{
			steer /= count; // Average the steering force
		}
		
		return steer;
	}

	// Rule 2: Alignment—Steer towards the average heading of neighbors
	private Vector2 Alignment()
	{
		if (_neighbors.Count == 0) return Vector2.Zero;

		Vector2 averageVelocity = Vector2.Zero;
		foreach (var neighbor in _neighbors)
		{
			averageVelocity += neighbor.Velocity;
		}
		averageVelocity /= _neighbors.Count;
		return averageVelocity.Normalized();
	}

	// Rule 3: Cohesion—Move towards the average position of neighbors
	private Vector2 Cohesion()
	{
		if (_neighbors.Count == 0) return Vector2.Zero;

		Vector2 centerOfMass = Vector2.Zero;
		foreach (var neighbor in _neighbors)
		{
			centerOfMass += neighbor.Position;
		}
		centerOfMass /= _neighbors.Count;

		Vector2 directionToCenter = centerOfMass - Position;
		return directionToCenter.Normalized();
	}
	
	private Vector2 FollowTarget()
	{
		if (_target == null) return Vector2.Zero;

		// This is the corrected line that uses world coordinates
		Vector2 desired = _target.GlobalPosition - this.GlobalPosition;
		
		float distance = desired.Length();

		// If the boid is far from the target, move towards it at full strength.
		if (distance > FollowRadius)
		{
			return desired.Normalized();
		}
		// If the boid is inside the follow radius, scale the force down.
		else if (distance > 0)
		{
			float magnitude = distance / FollowRadius;
			return desired.Normalized() * magnitude;
		}
		
		return Vector2.Zero;
	}
	
	private void BoidExitedScreen()
	{
		//GD.Print("Got here");
		Velocity *= -1;
		MoveAndSlide();
		
		// Optional: Make boid face its direction of movement
		LookAt(Position + Velocity);
	}
}
