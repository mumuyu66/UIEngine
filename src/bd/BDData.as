package bd
{
	import core.IDispose;

	public class BDData implements IDispose
	{
		private var _list : Vector.<BDUnit>;
		
		public var isInUser:Boolean=false;

		public function BDData(value : Vector.<BDUnit>)
		{
			_list = value;
		}
		
		public function getBDUnit(frame : int) : BDUnit
		{
			if (frame < 0 || frame >= _list.length) return null;
			return _list[frame];
		}

		public function addBDUnit(value : Vector.<BDUnit>) : void
		{
			if (!_list) _list = new Vector.<BDUnit>();
			_list = _list.concat(value);
		}

		public function list() : Vector.<BDUnit>
		{
			return _list;
		}

		public function get total() : int
		{
			return _list.length;
		}
		
		public function dispose() : void
		{
			if (_list == null) return;
			for each (var bds:BDUnit in _list)
			{
				bds.dispose();
			}
			_list.splice(0,_list.length);
		}
	}
}