class Block extends FlxSpriteExt
{
	public function new(?X:Float, ?Y:Float)
	{
		super(X, Y);

		makeGraphic(96, 96, FlxColor.WHITE);
		visible = false;

		PlayState.self.blocks.add(this);
	}

	override function update(elapsed:Float)
	{
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
}
