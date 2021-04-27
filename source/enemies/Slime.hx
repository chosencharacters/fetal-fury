package enemies;

class Slime extends Enemy
{
	var speed:Int = 150;
	var accel_frames:Int = 15;
	var detect_range:Float = 640;

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
			case "spawn":
				anim("move");
				ttick();
				if (tick > 60)
					sstateAnim("idle");
			case "idle":
				anim("idle");
				if (Utils.getDistanceM(this, clp()) < detect_range)
					sstateAnim("move");
			case "move":
				if (!isOnScreen() || PlayState.self.players.getFirstAlive() == null)
				{
					sstate("idle");
					return;
				}
				ttick();
				if (tick % 60 == 1)
					SoundPlayer.altSound(2, [AssetPaths.EnemyLandAfterJump1__ogg, AssetPaths.EnemyLandAfterJump2__ogg]);
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
