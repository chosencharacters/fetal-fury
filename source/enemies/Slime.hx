package enemies;

class Slime extends Enemy
{
	var speed:Int = 125;
	var accel_frames:Int = 15;

	var vision:Int = 0;

	public function new(?X:Float, ?Y:Float)
	{
		super(X, Y);

		loadAllFromAnimationSet("slime");

		maxVelocity.set(speed, speed);
		drag.set(100, 100);
		setSize(76, 62);
		offset.set(31, 46);

		health = 2;

		sstateAnim("idle");
	}

	override function ai()
	{
		super.ai();

		switch (state)
		{
			case "idle":
				if (Utils.getDistanceM(this, clp()) < 320)
					sstateAnim("move");
			case "move":
				pathfinding_chase_player(speed / accel_frames);
			case "hit":
				if (stun < 0 && animation.finished)
				{
					sstateAnim("idle");
					if (health <= 0)
						sstateAnim("kill");
				}
			case "kill":
				if (animation.finished)
					kill();
		}
	}
}
