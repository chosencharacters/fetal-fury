package levels;

import flixel.tile.FlxTilemap;

class LDTKLevel extends FlxTilemap
{
	var tile_size:Int = 96;

	var lvl_width:Int = 0;
	var lvl_height:Int = 0;
	var array_len:Int = 0;

	public function new(project:LdtkProject, level_name:String, graphic:String)
	{
		super();
		generate(project, level_name, graphic);
	}

	function generate(project:LdtkProject, level_name:String, graphic:String)
	{
		var data:LdtkProject_Level = get_level_by_name(project, level_name);

		lvl_width = Math.floor(data.pxWid / tile_size);
		lvl_height = Math.floor(data.pxHei / tile_size);
		array_len = lvl_width * lvl_height;

		loadMapFromArray([for (i in 0...array_len) 1], lvl_width, lvl_height, graphic, tile_size, tile_size);

		for (autoTile in data.l_Auto_Layer.autoTiles)
		{
			var index:Int = Math.floor(autoTile.renderX / tile_size + (autoTile.renderY / tile_size) * lvl_width);
			setTileByIndex(index, autoTile.tileId);
		}
	}

	function get_level_by_name(project:LdtkProject, level_name:String):LdtkProject_Level
	{
		for (data in project.levels)
		{
			if (data.identifier == level_name)
			{
				return data;
			}
		}
		throw "level does not exist by the name of '" + level_name + "'";
	}
}
