#if html5
import io.newgrounds.NG;
import io.newgrounds.NGLite;
import io.newgrounds.objects.ScoreBoard;
import io.newgrounds.swf.ScoreBrowser;
import lime.tools.GUID;

class NewgroundsHandler
{
	static var LOGGED_IN:Bool = false;
	static var USERNAME:String = "";
	static var SESSION_ID:String = "";

	public function new() {}

	public static function init(?callback:Void->Void)
	{
		/*
			Make sure this file exists, it's just a simple json that has this format
			{
				"app_id":"xxx",
				"encryption_key":"xxx"
			}
		 */
		var json = haxe.Json.parse(Utils.loadAssistString("assets/data/config/ng_api/ng_secrets.json"));

		NG.createAndCheckSession(json.app_id, true);
		NG.core.initEncryption(json.encryption_key);
		NG.core.onLogin.add(onNGLogin);

		if (NG.core.loggedIn == false)
			NG.core.requestLogin(function():Void
			{
				trace("manually logged in");
				Main.NG_LOGGED_IN = true;
			});
		else
			Main.NG_LOGGED_IN = true;
	}

	public static function medal_popup(id:Int)
	{
		trace(NGLite.getSessionId());
		trace("got medal");
		var medal = NG.core.medals.get(id);
		trace('${medal.name} #${medal.id} is worth ${medal.value} points!');
		trace(medal.icon);
		new NGMedalPopUp(medal.name, medal.icon);
	}

	public static function post_score(time_in_frames:Int, board_id:Int = 10255)
	{
		trace(NGLite.getSessionId());

		if (!NG.core.loggedIn)
		{
			trace("not logged in");
			return;
		}

		if (NG.core.scoreBoards == null)
			throw "Cannot access scoreboards until ngScoresLoaded is dispatched";

		if (!NG.core.scoreBoards.exists(board_id))
			throw "Invalid boardId:" + board_id;

		NG.core.scoreBoards.get(board_id).postScore(time_in_frames * 16);

		trace("Posted to " + NG.core.scoreBoards.get(board_id));
	}

	/**
	 * Note: Taken from Geokurelli's Advent class
	 */
	static function onNGLogin():Void
	{
		LOGGED_IN = true;
		USERNAME = NG.core.user.name;
		SESSION_ID = NGLite.getSessionId();

		trace('logged in! user:${USERNAME} session: ${SESSION_ID}');

		NG.core.requestMedals();
		NG.core.requestScoreBoards();
	}
}
#end
