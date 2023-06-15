package system;

import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import gameobjects.*;

class Reg
{
	public static var SPACING:Int;

	public static var GOAT_SIZE:Int;
	public static var SQUARE_SIZE:Int;
	public static var TOKEN_SIZE:Int;
	public static var RANK_SIZE:Int;
	public static var PANEL_HEIGHT:Int;
	public static var PANEL_WIDTH:Int;
	public static var PANEL_PLACEMENTS:Map<Int, FlxPoint>;

	public static var BOARD_X:Int;
	public static var BOARD_Y:Int;

	public static var DIE_SIZE:Int;
	public static var SLOT_WIDTH:Int;
	public static var DICEBOX_WIDTH:Int;
	public static var DICEBOX_HEIGHT:Int;
	public static var DICEBOX_X:Int;
	public static var DICEBOX_Y:Int;

	public static var MOVE_CONFIRM_X:Float;
	public static var MOVE_CONFIRM_Y:Float;
	public static var MOVE_CONFIRM_WIDTH:Int;
	public static var MOVE_CONFIRM_HEIGHT:Int;

	public static var centerX:Float;
	public static var centerY:Float;
	public static var nonUIWidth:Int;
	public static var nonUIHeight:Int;

	public static var maxMoveTime:Float;

	public static var backgroundColor:FlxColor;
	public static var playerColors:Map<Int, FlxColor>;
	public static var playerTextColors:Map<Int, FlxColor>;

	public static function initReg()
	{
		SPACING = 9;

		GOAT_SIZE = 60;
		SQUARE_SIZE = 100;
		TOKEN_SIZE = 60;
		RANK_SIZE = 120;
		PANEL_HEIGHT = 97;
		PANEL_WIDTH = TOKEN_SIZE * 6 + RANK_SIZE;

		BOARD_X = Math.round((FlxG.width - 2 * PANEL_HEIGHT - 6 * SQUARE_SIZE) / 2 + PANEL_HEIGHT);
		BOARD_Y = Math.round((FlxG.height - 2 * PANEL_HEIGHT - 5 * SQUARE_SIZE - TOKEN_SIZE) / 2 + PANEL_HEIGHT);
		DIE_SIZE = 45;
		DICEBOX_HEIGHT = 4 * DIE_SIZE + 2 * SPACING;
		DICEBOX_WIDTH = 4 * DIE_SIZE + 2 * SPACING;
		DICEBOX_X = FlxG.width - DICEBOX_WIDTH;
		DICEBOX_Y = FlxG.height - DICEBOX_HEIGHT;

		MOVE_CONFIRM_WIDTH = 221;
		MOVE_CONFIRM_HEIGHT = 98;
		MOVE_CONFIRM_X = DICEBOX_X - MOVE_CONFIRM_WIDTH - SPACING;
		MOVE_CONFIRM_Y = DICEBOX_Y;

		centerX = FlxG.width / 2;
		centerY = FlxG.height / 2;
		nonUIWidth = FlxG.width - 2 * Reg.PANEL_HEIGHT;
		nonUIHeight = FlxG.height - 2 * Reg.PANEL_HEIGHT;

		PANEL_PLACEMENTS = [
			0 => FlxPoint.get(DICEBOX_X - SPACING - PANEL_WIDTH / 2, FlxG.height - PANEL_HEIGHT / 2),
			1 => FlxPoint.get(FlxG.width - PANEL_HEIGHT / 2, DICEBOX_Y - SPACING - PANEL_WIDTH / 2),
			2 => FlxPoint.get(DICEBOX_X - SPACING - PANEL_WIDTH / 2, PANEL_HEIGHT / 2),
			3 => FlxPoint.get(PANEL_HEIGHT / 2, DICEBOX_Y - SPACING - PANEL_WIDTH / 2)
		];

		maxMoveTime = 0.4;
	}
}
