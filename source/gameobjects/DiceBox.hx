package gameobjects;

import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import gadgets.*;
import gameobjects.*;
import system.*;
import system.Data;

class DiceBox implements IDObject extends FlxSprite
{
	private var locales:Array<Locale>;

	public var queryRegion:QueryRegion;

	public var dice:Array<Die>;

	public var slotCounts:Array<Int>;
	public var oneCount:Int;

	public function new(x, y, color:FlxColor)
	{
		super(x, y);
		queryRegion = new QueryRegion().addRegionGrid(x + Reg.SPACING, y + Reg.SPACING, 4 * Reg.DIE_SIZE, 4 * Reg.DIE_SIZE, 1, 4);
		locales = [];
		dice = [];
		for (i in 0...4)
		{
			locales.push(new GridLocale(x + i * Reg.DIE_SIZE + Reg.SPACING, y + Reg.SPACING, Reg.DIE_SIZE, 4 * Reg.DIE_SIZE, 4, 1));
			initDie(i);
		}
		loadGraphic("assets/dicebox.png");
		System.mouse.initClickable(this);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	function initDie(slot:Int):Die
	{
		var die = new Die();
		toSlot(slot, die);
		die.teleportMode = false;
		dice.push(die);
		return die;
	}

	public function toSlot(slot:Int, die:Die, callback:Null<Gamepiece->Void> = null)
	{
		locales[slot].add(die, callback);
		die.slot = slot;
		updateSlotValues();
	}

	public function updateSlotValues()
	{
		slotCounts = [0, 0, 0, 0];
		oneCount = 0;
		for (die in dice)
		{
			slotCounts[die.slot] += die.value;
			oneCount = die.value == 1 ? oneCount + 1 : oneCount;
		}
	}

	public function judgeMovements(movements:Map<Int, Int>):Map<Int, Bool>
	{
		for (die in dice)
		{
			die.toggleReserve(false);
		}
		var output:Map<Int, Bool> = [];
		var diceBySlot:Array<Array<Die>> = [[], [], [], []];
		for (die in dice)
		{
			diceBySlot[die.slot].push(die);
		}
		for (mountain in 5...11)
		{
			if (movements[mountain] == 0)
			{
				output[mountain] = true;
				continue;
			}
			var isValidMovement:Bool = false;
			var reserved:Array<Int> = []; // Reserved slots, for moves that can be executed.
			for (slot in 0...4)
			{
				if (slotCounts[slot] == mountain)
				{
					reserved.push(slot);
				}
				if (reserved.length == movements[mountain])
				{
					isValidMovement = true;
					break;
				}
			}
			output[mountain] = isValidMovement;
			if (isValidMovement)
			{
				for (slot in reserved)
				{
					for (die in diceBySlot[slot])
					{
						die.toggleReserve(true);
					}
				}
			}
		}
		return output;
	}

	public function unreserveAll()
	{
		for (die in dice)
		{
			die.toggleReserve(false);
		}
	}

	/*private function validSlotForvalues:Array<Int>, mountain:Int, sum:Int):Null<Int>
		{
			if (sum == mountain)
			{
				return 0;
			}
			if (sum > mountain)
			{
				return null;
			}
			var wildCounts:Int = 0;
			for (value in values)
			{
				if (value == 1)
				{
					wildCounts += 1;
				}
			}
			for (wildsNeeded in 1...wildCounts + 1)
			{
				if (sum + 5 * wildsNeeded >= mountain)
				{
					return wildsNeeded;
				}
			}
			return null;
	}*/
	public function id()
	{
		return DiceBoxID(this);
	}
}
