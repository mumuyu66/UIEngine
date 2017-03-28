package net {
	import flash.events.EventDispatcher;
	import flash.utils.getTimer;

	/**
	 * @author yangyiqiang
	 */
	public class PreloadModel extends EventDispatcher
	{
		public static const MAX : int = 2;

		private var _loaderV : Vector.<ALoader>=new Vector.<ALoader>();

		private var _loadIng : Vector.<ALoader>=new Vector.<ALoader>();

		private var _timer:uint;
		
		/**
		 * 状态
		 * 0: 正常
		 * 1: 暂停
		 */
		private var _state:int=0;
		public function add(loader : ALoader) : void
		{
			_timer=getTimer();
			_loaderV.push(loader);
			if (_loadIng.length < MAX) loadNext();
		}

		public function remove(loader : ALoader) : void
		{
			if (!loader) return;
			loader.stop();
			var index : int = _loaderV.indexOf(loader);
			if (index >= 0)
			{
				_loaderV.splice(index,1);
			}
			else
			{
				index = _loadIng.indexOf(loader);
				if (index >= 0){
					_loadIng.splice(index,1) as ALoader;
				}
				loadNext();
			}
		}

		private function loadNext() : void
		{
			if (_loaderV.length == 0) return;
			_loadIng[_loadIng.push(_loaderV.shift())-1].load();
		}

		public function pause() : void
		{
			if(_state==1)return;
			_state=1;
			for each (var loader:ALoader in _loadIng)
				loader.stop();
		}

		public function resume() : void
		{
			if(_state!=1)return;
			if (_loadIng.length == 0)
			{
				loadNext();
				return;
			}
			for each (var loade:ALoader in _loadIng)
				loade.load();
		}
	}
}
