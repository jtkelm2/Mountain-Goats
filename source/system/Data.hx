package system;

import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.ui.FlxButton;
import gadgets.*;
import gameobjects.*;
import states.*;

enum ObjectID
{
	GoatID(goat:Goat);
	DieID(die:Die);
	SquareID(square:Square);
	DiceBoxID(diceBox:DiceBox);
	TokenID(token:Token);
	MoveConfirmButtonID(button:FlxButton);
}

enum Tag
{
	GoatTag;
	DieTag;
	SquareTag;
	DiceBoxTag;
	TokenTag;

	DiceRollingGSTag;
	PlanningGSTag;
	GameoverGSTag;
	MoveConfirmButtonTag;
}

enum KeyID
{
	Spacebar;
}

enum PlayerID
{
	Human;
	AI(ai:AI);
}

enum EventID
{
	MouseDown(objectID:ObjectID);
	MouseUp(objectID:ObjectID);
	MouseOver(objectID:ObjectID);
	MouseOut(objectID:ObjectID);
	MouseWheel(objectID:ObjectID);
	KeyPressed(key:KeyID);
	KeyReleased(key:KeyID);
	DraggerDropped(objectID:ObjectID);
	MouseClicked;
	MovementsConfirmed;
	SwitchState(gamestate:Gamestate);

	AICastWild(die:Die, value:Int);
	AIPlaceDie(die:Die, slot:Int);
	AIAdvanceGoat(mountain:Int);
}

interface IDObject extends IFlxSprite
{
	public function id():ObjectID;
}

interface Gamestate // extends IFlxBasic
{
	public function handle(event:EventID):Void;
	public function refresh():Gamestate;
	public var gamestateTag:Tag;
}

interface Gamepiece extends IDObject
{
	public var inLocale:Null<Locale>;
	public function moveTo(x:Float, y:Float, callback:Null<Gamepiece->Void> = null):Void;
	public var isMoving:Bool;
}

interface AI
{
	public function onPrompt(gamestate:Gamestate):Void;
}

enum SquareType
{
	Mountaintop;
	Mountain;
	MountainFoot;
}

enum TokenType
{
	MountainToken(n:Int);
	BonusToken(n:Int);
}

class Data
{
	public var tags = [GoatTag, DieTag, SquareTag, DiceBoxTag];

	public function new() {}

	public function fromID(objectID:ObjectID):FlxSprite
	{
		switch (objectID)
		{
			case GoatID(goat):
				return goat;
			case DieID(die):
				return die;
			case SquareID(square):
				return square;
			case DiceBoxID(diceBox):
				return diceBox;
			case TokenID(token):
				return token;
			case MoveConfirmButtonID(button):
				return button;
		}
	}

	public function idToTag(objectID:ObjectID):Tag
	{
		switch objectID
		{
			case GoatID(_):
				return GoatTag;
			case DieID(_):
				return DieTag;
			case SquareID(_):
				return SquareTag;
			case DiceBoxID(_):
				return DiceBoxTag;
			case TokenID(_):
				return TokenTag;
			case MoveConfirmButtonID(_):
				return MoveConfirmButtonTag;
		}
	}

	public function toTag(gamepiece:Gamepiece):Tag
	{
		return idToTag(gamepiece.id());
	}
}
