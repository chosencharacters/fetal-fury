package actors;

import flixel.util.FlxPath;

class Enemy extends Actor
{
	var follow_path:Array<FlxPoint>;
	var pathfinding_tick:Int = 10;

	var DYING:Bool = false;
	var SUPER_ARMORED:Bool = false;

	public var grabbable:Bool = true;

	public function new(?X:Float, ?Y:Float)
	{
		super(X, Y);
		types.push("enemy");
		team = -1;

		PlayState.self.enemies.add(this);
	}

	override function update(elapsed:Float)
	{
		ai();
		super.update(elapsed);
	}

	override function hitM(m:Melee):Bool
	{
		if (DYING)
			return false;

		var result:Bool = super.hitM(m);

		if (justHit && state != "kill" && !DYING)
		{
			if (!SUPER_ARMORED)
			{
				animation.reset();
				sstateAnim("hit");
				SoundPlayer.altSound(3, [AssetPaths.EnemyIsHit1__ogg, AssetPaths.EnemyIsHit2__ogg], 1);
			}
			if (health <= 0)
				DYING = true;
		}

		return result;
	}

	/**
	 * This enemy does impact damage
	 * @return Bool did deal it impact?
	 */
	function melee_hit_player():Bool
	{
		if (stun > 0)
			return false;
		for (p in PlayState.self.players)
		{
			if (p.inv < 0 && overlaps(p) && FlxG.pixelPerfectOverlap(this, p))
			{
				p.hit(this, str, 10, FlxPoint.weak(500, 500));
				return true;
			}
		}
		return false;
	}

	function ai() {}

	override function kill()
	{
		PlayState.self.enemies.remove(this, true);
		super.kill();
	}

	/**
	 * Finds closest player
	 * @return Player
	 */
	public function clp():Player
	{
		var least:Float = 0;
		var rp:Player = PlayState.self.players.members[0];
		for (p in PlayState.self.players)
		{
			var t:Float = Utils.getDistanceM(this, p);
			if ((t < least || least == 0) && p.alive)
			{
				least = t;
				rp = p;
			}
		}
		return rp;
	}

	/**
	 * Chases the player around at an accelerating speed
	 * @param accel_rate speed to chase
	 */
	public function chase_player(accel_rate:Float, auto_turn:Bool = true)
	{
		var mp1:FlxPoint = getMidpoint(FlxPoint.weak());
		var mp2:FlxPoint = clp().getMidpoint(FlxPoint.weak());
		if (mp1.x < mp2.x)
		{
			velocity.x += accel_rate;
			if (auto_turn)
				flipX = true;
		}
		if (mp1.x > mp2.x)
		{
			velocity.x -= accel_rate;
			if (auto_turn)
				flipX = false;
		}
		if (mp1.y < mp2.y)
			velocity.y += accel_rate;
		if (mp1.y > mp2.y)
			velocity.y -= accel_rate;
	}

	/**
	 * Chases the player around at an accelerating speed
	 * @param accel_rate speed to chase
	 */
	public function pathfinding_chase_player(accel_rate:Float, auto_turn:Bool = true)
	{
		var mp1:FlxPoint = getMidpoint(FlxPoint.weak());
		var mp2:FlxPoint = clp().getMidpoint(FlxPoint.weak());

		if (pathfinding_tick % 15 == 0)
			follow_path = PlayState.self.level.col.findPath(mp1, mp2);

		pathfinding_tick++;

		if (follow_path == null || follow_path.length < 2)
		{
			chase_player(accel_rate, auto_turn);
			return;
		}

		mp2 = follow_path[1];

		if (auto_turn)
			flipX = clp().x > x;
		if (mp1.x < mp2.x)
			velocity.x += accel_rate;
		if (mp1.x > mp2.x)
			velocity.x -= accel_rate;
		if (mp1.y < mp2.y)
			velocity.y += accel_rate;
		if (mp1.y > mp2.y)
			velocity.y -= accel_rate;
	}
}
