package net {
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class LoadModel extends EventDispatcher
	{
		public static const MAX : int = 5;

		private var _list : Array;

		private var _done : int;

		private var _total : int;

		private var _speed : int;

		private var _progress : int;

		public function calc() : void
		{
			var count : int = 0;
			var speed : int = 0;
			for each (var data:LoadData in _list)
			{
				speed += data.speed;
				if (data.isComplete())continue;
				count += data.percent;
			}
			var progress : int = count>100?100:count;
			if (_progress == progress) return;
			_progress = progress;
			_speed = speed / _list.length;
		}

		public function LoadModel()
		{
			_list = new Array();
		}

		public function hasFree() : Boolean
		{
			return _list.length < MAX;
		}

		public function add(data : LoadData) : void
		{
			if (_list.length >= MAX) return;
			_list.push(data);
		}

		public function remove(data : LoadData) : void
		{
			var index : int = _list.indexOf(data);
			if (index != -1)
			{
				_done++;
				if (_done > _total) _done = _total;
				_progress =100;
				_list.splice(index, 1);
				dispatchEvent(new Event(Event.CANCEL));
			}
		}

		public function reset(value : int) : void
		{
			_progress = 0;
			_total = value;
			_done = 0;
			_speed = 0;
			dispatchEvent(new Event(Event.INIT));
		}

		public function end() : void
		{
			dispatchEvent(new Event(Event.COMPLETE));
		}

		public function get done() : int
		{
			return _done;
		}

		public function get progress() : int
		{
			return _progress;
		}

		public function get speed() : int
		{
			return _speed;
		}

		public function get total() : int
		{
			return _total;
		}
	}
}