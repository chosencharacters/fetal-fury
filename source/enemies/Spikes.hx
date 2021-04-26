package enemies;

import actors.Melee;

class Spikes extends Enemy
{
	public function new(?X:Float, ?Y:Float)
	{
		super(X, Y);
		makeGraphic(96, 96);
		visible = false;
		immovable = true;

		str = 1;

		DROP_SHADOW_DISABLE = true;

		grabbable = false;

		team = 0;
	}

	override function ai()
	{
		if (BaseState.WIPING || PlayState.self.LEVEL_CLEAR)
			return;
		melee_hit_player();
		super.ai();
	}

	override function hitM(m:Melee):Bool
	{
		return false;
	}
}
