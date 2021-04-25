package actors;

import flixel.util.FlxPath;

class Enemy extends Actor
{
	var follow_path:Array<FlxPoint>;
	var pathfinding_tick:Int = 10;

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
		var result:Bool = super.hitM(m);

		if (justHit && state != "kill")
		{
			trace("hit!!!");
			animation.reset();
			sstateAnim("hit");
		}

		return result;
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

		/*
			var debug:FlxPath = new FlxPath();
			FlxG.debugger.drawDebug = true;
			debug.drawDebug(FlxG.camera);
		 */

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
