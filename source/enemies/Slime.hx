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
		str = 1;

		sstate("idle");
	}

	override function ai()
	{
		if (BaseState.WIPING || PlayState.self.LEVEL_CLEAR)
		{
			velocity.set(0, 0);
			animation.pause();
			return;
		}
		super.ai();

		switch (state)
		{
			case "idle":
				animProtect("idle");
				if (Utils.getDistanceM(this, clp()) < 320)
					sstateAnim("move");
			case "move":
				pathfinding_chase_player(speed / accel_frames);
				melee_hit_player();
			case "hit":
				if (stun < 0 && animation.finished)
				{
					sstateAnim("idle");
					if (health <= 0)
						sstateAnim("kill");
				}
			case "kill":
				if (animation.finished)
				{
					// blood_explode();
					kill();
				}
		}
	}
}
