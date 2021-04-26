package levels;

import enemies.Slime;
import flixel.tile.FlxTilemap;
import platforms.Exit;

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
		for (i in [0, 2, 3, 4])
			col.setTileProperties(i, FlxObject.NONE);

		place_entities(project, level_name);
	}

	function place_entities(project:LdtkProject, level_name:String)
	{
		var data = get_level_by_name(project, level_name);

		for (entity in data.l_Friendlies.all_Player.iterator())
			new Player(entity.pixelX, entity.pixelY);
		for (entity in data.l_Enemies.all_Slime.iterator())
			new Slime(entity.pixelX, entity.pixelY);
		for (entity in data.l_Enemies.all_Exit.iterator())
			new Exit(entity.pixelX, entity.pixelY);
	}
}
