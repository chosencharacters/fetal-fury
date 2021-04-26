package enemies;

class SlimeSmol extends Enemy
{
	var speed:Int = 200;
	var accel_frames:Int = 15;
	var detect_range:Float = 900;

	var vision:Int = 0;

	public function new(?X:Float, ?Y:Float)
	{
		super(X, Y);

		loadAllFromAnimationSet("slime_smol");

		maxVelocity.set(speed, speed);
		drag.set(100, 100);
		setSize(71, 71);
		offset.set(9, 0);

		health = 1;
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
				if (Utils.getDistanceM(this, clp()) < detect_range)
					sstateAnim("move");
			case "move":
				pathfinding_chase_player(speed / accel_frames);
				melee_hit_player();
			case "hit":
				sstate("kill");
				ai();
			case "kill":
				blood_explode();
				kill();
		}
	}
}
