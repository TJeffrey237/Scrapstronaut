using Godot;
using System;

public partial class BoidSpawner : Node2D
{
	[Export] public int NumberOfBoids = 10;
	[Export] public PackedScene BoidScene;
	private CharacterBody2D _target;

	public override void _Ready()
	{
		_target = GetTree().GetFirstNodeInGroup("BoidTarget") as CharacterBody2D;
		if (BoidScene == null)
		{
			GD.PrintErr("BoidSpawner: BoidScene not set.");
			return;
		}
	}
	
	public void CoinCollect()
	{
		for(int i = 0; i < NumberOfBoids; i++)
		{
			SpawnBoid();
		}
	}

	private void SpawnBoid()
	{
		Boid boid = BoidScene.Instantiate<Boid>();
		boid.SetTarget(_target);
		AddChild(boid);
	}
}
