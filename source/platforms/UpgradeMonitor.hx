package platforms;

import actors.Melee;

class UpgradeMonitor extends Actor
{
	var stem:FlxSpriteExt;

	static var monitor_switch:Int = 0;

	var upgrade_pool:Array<String> = ["speed", "time", "attack"];
	var upgrade_type:String = "";

	var col_group:FlxTypedGroup<FlxSpriteExt> = new FlxTypedGroup<FlxSpriteExt>();

	var boom:TempSprite;

	var DESTROYED:Bool = false;
	var DELAY_DESTROY:Bool = false;

	public var INACTIVE:Bool = false;

	public function new(?X:Float, ?Y:Float)
	{
		super(X - 37, Y - 53);

		team = -1;
		health = 1;

		loadAllFromAnimationSet("upgrade_monitor");
		stem = new FlxSpriteExt(x + 42, y - 319, AssetPaths.monitor_pole__png);

		PlayState.self.upgrades.add(this);
		PlayState.self.miscBack.add(stem);

		upgrade_type = upgrade_pool[monitor_switch % 3];
		anim(upgrade_type);
		monitor_switch++;

		immovable = true;
		stem.immovable = true;

		col_group.add(this);
		col_group.add(stem);

		moves = false;
	}

	override function update(elapsed:Float)
	{
		FlxG.collide(col_group, PlayState.self.players);

		if (boom != null && boom.animation.frameIndex >= 2)
			anim("destroyed");

		ttick();

		for (p in PlayState.self.players)
		{
			if (overlaps(p))
			{
				var mp1:FlxPoint = getMidpoint(FlxPoint.weak());
				var mp2:FlxPoint = p.getMidpoint(FlxPoint.weak());
				if (mp1.x > mp2.x)
					p.x -= 4;
				if (mp1.x < mp2.x)
					p.x += 4;
			}
		}

		super.update(elapsed);
	}

	override function hitM(m:Melee):Bool
	{
		if (INACTIVE || DESTROYED)
			return false;

		var result:Bool = super.hitM(m);
		return super.hitM(m);
	}

	override function killAssist()
	{
		if (!DESTROYED)
		{
			detonate();
			turn_off_other_monitors();
		}
		super.killAssist();
	}

	function detonate()
	{
		DESTROYED = true;
		boom = new TempSprite(x - 125, y - 210);
		boom.loadAllFromAnimationSet("upgrade_monitor_explosion");
		PlayState.self.miscBack.add(boom);
		SoundPlayer.play_sound(AssetPaths.upgrade_explosion__ogg);

		for (p in PlayState.self.players)
		{
			p.upgrade(upgrade_type);
		}
	}

	function turn_off_other_monitors()
	{
		for (u in PlayState.self.upgrades)
		{
			if (u != this)
			{
				u.anim("empty");
				u.INACTIVE = true;
			}
		}
	}
}
