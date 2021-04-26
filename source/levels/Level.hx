package levels;

import enemies.*;
import flixel.tile.FlxTilemap;
import platforms.Block;
import platforms.Exit;
import platforms.UpgradeMonitor;

class Level extends LDTKLevel
{
	public var col:FlxTilemap;

	public function new(project:LdtkProject, level_name:String, graphic:String)
	{
		super(project, level_name, graphic);
	}

	override function generate(project:LdtkProject, level_name:String, graphic:String)
	{
		super.generate(project, level_name, graphic);

		for (i in 0..._tileObjects.length)
			setTileProperties(i, FlxObject.NONE);

		var data = get_level_by_name(project, level_name);

		col = new FlxTilemap();
		col.loadMapFromArray([for (i in 0...array_len) 1], lvl_width, lvl_height, graphic, tile_size, tile_size);

		for (key in data.l_Auto_Source.intGrid.keys())
			col.setTileByIndex(key, data.l_Auto_Source.intGrid.get(key));
		for (i in [0, 3, 4])
			col.setTileProperties(i, FlxObject.NONE);

		place_entities(project, level_name);
	}

	function place_entities(project:LdtkProject, level_name:String)
	{
		var data = get_level_by_name(project, level_name);

		for (entity in data.l_Friendlies.all_Player.iterator())
			new Player(entity.pixelX, entity.pixelY);
		for (entity in data.l_Friendlies.all_Upgrade.iterator())
			new UpgradeMonitor(entity.pixelX, entity.pixelY);
		for (entity in data.l_Enemies.all_Slime.iterator())
			new Slime(entity.pixelX, entity.pixelY);
		for (entity in data.l_Enemies.all_Slime_Smol.iterator())
			new SlimeSmol(entity.pixelX, entity.pixelY);
		for (entity in data.l_Enemies.all_Slime_Medium.iterator())
			new SlimeMedium(entity.pixelX, entity.pixelY);
		for (entity in data.l_Enemies.all_Slime_Boss.iterator())
			new SlimeBoss(entity.pixelX, entity.pixelY);

		for (index in 0...col.totalTiles)
		{
			var pos:FlxPoint = col.getTileCoordsByIndex(index);
			pos.subtract(tile_size / 2, tile_size / 2);
			switch (col.getTileByIndex(index))
			{
				case 2:
					new Block(pos.x, pos.y);
				case 4:
					new Exit(pos.x, pos.y);
			}
		}
	}
}
