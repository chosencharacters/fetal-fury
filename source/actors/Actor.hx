package actors;

class Actor extends FlxSpriteExt
{
	var team:Int = 0;

	/**Knockback resistence, lower the higher*/
	var sturdiness:FlxPoint = new FlxPoint(1, 1);

	/**Did I just receive damage?*/
	var justHit:Bool = false;

	/**Strength i.e. base damage*/
	var str:Int = 0;

	/**Stun i.e. disable time*/
	var stun:Int = 0;

	/**Invulnerability i.e. can't be hit time*/
	var inv:Int = 0;

	/**Circle below all actors */
	var drop_shadow:FlxSpriteExt;

	/**Disable drop shadow effect*/
	var DROP_SHADOW_DISABLE:Bool = false;

	var melee_history:Map<Int, Int> = new Map<Int, Int>();

	public function new(?X:Float, ?Y:Float)
	{
		super(X, Y);

		types.push("actor");

		drop_shadow = new FlxSpriteExt(-999, 999, AssetPaths.drop_shadow__png);
		PlayState.self.miscBack.add(drop_shadow);
	}

	override function update(elapsed:Float)
	{
		stun--;
		inv--;

		justHit = false;

		if (stun <= 0)
		{
			for (m in melee_history.keys())
			{
				melee_history.set(m, melee_history.get(m) - 1);
				if (melee_history.get(m) <= 0)
					melee_history.remove(m);
			}
		}

		super.update(elapsed);
		update_drop_shadow();
	}

	function damage(Damage:Int, ?Stun:Int = 0, SourcePoint:FlxPoint, Knockback:FlxPoint)
	{
		health -= Damage;
		if (health <= 0)
			killAssist();

		var mp:FlxPoint = getMidpoint(FlxPoint.weak());
		var kb:FlxPoint = FlxPoint.weak(Knockback.x * sturdiness.x, Knockback.y * sturdiness.y);

		kb.x = mp.x > SourcePoint.x ? kb.x : -kb.x;
		kb.y = mp.y > SourcePoint.y ? kb.y : -kb.y;

		velocity.add(kb.x, kb.y);

		// Stun doesn't override existing stun if it's smaller, just adds to it
		stun = Stun > stun ? Stun : stun + Stun;

		PlayState.self.hitstop = 5;
		Utils.shake("damagelight");
	}

	public function hitM(m:Melee):Bool
	{
		var invulnerable:Bool = inv > 0 || melee_history.get(m.melee_id) > 0;
		var opposite_team:Bool = m.team == 0 || m.team > 0 && team < 0 || m.team < 0 && team > 0;
		if (invulnerable || !opposite_team || !overlaps(this) || !FlxG.pixelPerfectOverlap(this, m))
			return false;

		damage(m.str, m.stun, m.getMidpoint(FlxPoint.weak()), m.knockback);
		melee_history.set(m.melee_id, 10);

		inv = 10;
		justHit = true;
		return justHit;
	}

	/**
	 * Gets called instead of kill by default, just in case actors have a special something to do before they die ex. a special death animation
	 */
	function killAssist() {}

	/**
	 * Updates the drop shadow
	 */
	function update_drop_shadow()
	{
		drop_shadow.visible = !DROP_SHADOW_DISABLE;

		if (DROP_SHADOW_DISABLE)
			return;

		var mp:FlxPoint = getMidpoint(FlxPoint.weak());
		drop_shadow.setPosition(mp.x - drop_shadow.width / 2, y + height - drop_shadow.height / 1.5);

		drop_shadow.velocity.copyFrom(velocity);
		drop_shadow.acceleration.copyFrom(acceleration);
		drop_shadow.drag.copyFrom(drag);
	}

	override function kill()
	{
		DROP_SHADOW_DISABLE = true;
		update_drop_shadow();
		super.kill();
	}
}
