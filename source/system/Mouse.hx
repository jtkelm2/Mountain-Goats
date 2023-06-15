package system;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.mouse.FlxMouseEvent;
import system.*;
import system.Data;

class Mouse extends FlxBasic
{
	public var hovered:Null<ObjectID>;

	private var clickableRegistry:Map<Tag, Array<FlxSprite>>;

	public function new()
	{
		super();
		hovered = null;
		clickableRegistry = [];
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.mouse.justPressed)
		{
			System.events.handle(MouseClicked);
		}
	}

	public function initClickable(clickable:IDObject)
	{
		var clickableID = clickable.id();
		var clickableSprite = System.data.fromID(clickableID);
		var tag = System.data.idToTag(clickableID);

		if (clickableRegistry[tag] == null)
		{
			clickableRegistry[tag] = [];
		}

		FlxMouseEvent.add(clickableSprite, (_) ->
		{
			System.events.handle(MouseDown(clickableID));
		}, (_) ->
			{
				System.events.handle(MouseUp(clickableID));
			}, (_) ->
			{
				hovered = clickableID;
				System.events.handle(MouseOver(clickableID));
			}, (_) ->
			{
				if (hovered == clickableID)
				{
					hovered = null;
				}
				System.events.handle(MouseOut(clickableID));
			});
		FlxMouseEvent.setMouseWheelCallback(clickableSprite, _ ->
		{
			System.events.handle(MouseWheel(clickableID));
		});

		clickableRegistry[tag].push(clickableSprite);
	}

	public function clickableToggle(tag:Tag, bool:Bool)
	{
		for (clickable in clickableRegistry[tag])
		{
			FlxMouseEvent.setObjectMouseEnabled(clickable, bool);
		}
	}

	public function setActive(activeTags:Array<Tag>)
	{
		for (tag in clickableRegistry.keys())
		{
			var bool = activeTags.contains(tag);
			clickableToggle(tag, bool);
		}
	}
}
