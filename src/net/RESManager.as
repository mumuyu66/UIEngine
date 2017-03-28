package net
{
	import flash.display.Sprite;
	import log4a.Logger;
	import log4a.LogError;

	import utils.DictionaryUtil;
	import utils.ObjectPool;

	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	public class RESManager extends EventDispatcher
	{
		public static const SWF_TYPE : int = 0;

		public static const XML_TYPE : int = 1;

		private static var _creating : Boolean = false;

		private static var _instance : RESManager;

		private static var _list : Array = [];

		private static var _wait : Dictionary = new Dictionary(true);

		private static var _loaded : Dictionary = new Dictionary(true);

		private var _model : LoadModel;

		private var _preModel : PreloadModel;

		private function init() : void
		{
			_model = new LoadModel();
			_preModel = new PreloadModel();
		}

		private function loadNext() : void
		{
			var loader : ALoader;
			while (_model.hasFree())
			{
				if (_list.length == 0) return;
				loader = ALoader(_list.shift());
				_model.add(loader.loadData);
				loader.completeFun = completeHandler;
				loader.errorFun = errorHandler;
				loader.load();
			}
		}

		private function completeHandler(loader : ALoader) : void
		{
			_model.remove(loader.loadData);
			_preModel.remove(loader);
			delete _wait[loader.key];
			delete _otherLoader[loader.key];
			if (loader.isCache)
				_loaded[loader.key] = loader;
			else
				loader.stop();
			if (_list.length > 0)
			{
				loadNext();
			}
			else if (DictionaryUtil.isEmpty(_wait))
			{
				_model.end();
				_preModel.resume();
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}

		private function errorHandler(loader : ALoader) : void
		{
			_model.remove(loader.loadData);
			_preModel.remove(loader);
			delete _wait[loader.key];
			delete _otherLoader[loader.key];
			if (_list.length > 0)
			{
				loadNext();
			}
			else if (DictionaryUtil.isEmpty(_wait))
			{
				_model.end();
				_preModel.resume();
				dispatchEvent(new Event(Event.COMPLETE));
				Logger.debug("errorHandler===> new Event(Event.COMPLETE)");
			}
		}

		public function RESManager()
		{
			if (!_creating)
			{
				throw (new LogError("Class cannot be instantiated.Use RESManager.instance instead."));
			}
			init();
		}

		public static function get instance() : RESManager
		{
			if (_instance == null)
			{
				_creating = true;
				_instance = new RESManager();
				_creating = false;
			}
			return _instance;
		}

		public static function getBitmapData(asset : AssetData) : BitmapData
		{
			var loader : SWFLoader = _loaded[asset.libId] as SWFLoader;
			if (!loader)
			{
				return null;
			}
			var _class : Class = loader.getClass(asset.className);
			if (_class)
			{
				loader.userNum++;
				return new _class as BitmapData;
			}
			return null;
		}

		public static function getMC(asset : AssetData) :MovieClip
		{
			return getObj(asset);
		}

		public static function getObj(asset : AssetData) : *
		{
			var loader : SWFLoader = _loaded[asset.libId] as SWFLoader;
			if (!loader)
			{
				return null;
			}
			loader.userNum++;
			return loader.getObj(asset.className);
		}
		
		public static function getSprite(asset : AssetData) :Sprite
		{
			return getObj(asset);
		}

		public static function getClass(asset : AssetData) : Class
		{
			var loader : SWFLoader = _loaded[asset.libId] as SWFLoader;
			if (!loader)
			{
				return null;
			}
			loader.userNum++;
			return loader.getClass(asset.className);
		}

		public static function getByteArray(key : String) : ByteArray
		{
			var loader : RESLoader = _loaded[key] as RESLoader;
			if (loader == null) return null;
			loader.userNum++;
			return loader.getByteArray();
		}

		public static function getLoader(key : String) : SWFLoader
		{
			if ( _loaded[key]) _loaded[key]["userNum"]++;
			return  _loaded[key];
		}

		public function add(loader : ALoader) : void
		{
			var key : String = loader.key;
			if (loader.isLoaded)
			{
				_loaded[key] = loader;
				return;
			}
			if (_loaded[key] != null)
				return;
			if (_wait[key] != null)
			{
				if (loader.isRepeat)
					(_wait[key] as ALoader).funArray = (_wait[key] as ALoader).funArray.concat(loader.funArray);
				return;
			}
			if (_otherLoader[key] != null)
			{
				(_otherLoader[key] as ALoader).stop();
			}
			_list.push(loader);
			_wait[key] = loader;
		}

		public function remove(key : String,force:Boolean=true) : void
		{
			if(!force&&_otherLoader[key])return;
			if (_loaded[key] && (_loaded[key] is SWFLoader)) SWFLoader(_loaded[key]).clear();
			if (_otherLoader[key] && (_otherLoader[key] is SWFLoader)) SWFLoader(_otherLoader[key]).clear();
			if (_wait[key] && (_wait[key] is SWFLoader)) SWFLoader(_wait[key]).clear();
			delete _otherLoader[key];
			delete _wait[key];
			delete _loaded[key];
		}

		public function get model() : LoadModel
		{
			return _model;
		}

		/**
		 * 以队列形式加载
		 */
		public function startLoad() : void
		{
			Logger.debug("startLoad");
			if (_list.length == 0)
			{
				Logger.debug("startLoad  _list.length == 0");
				_model.end();
				dispatchEvent(new Event(Event.COMPLETE));
				return;
			}
			_preModel.pause();
			_model.reset(_list.length);
			loadNext();
		}

		private static var _otherLoader : Dictionary = new Dictionary(true);

		public function load(lib : LibData, onComplete : Function = null, onCompleteParams : Array = null) : void
		{
			if (!lib) return;
			if (_loaded[lib.key] != null)
			{
				if (onComplete != null) onComplete.apply(null, onCompleteParams);
				return;
			}
			if (_otherLoader[lib.key] != null)
			{
				if (lib.isRepeat)
					(_otherLoader[lib.key] as ALoader).funArray.push({fun:onComplete, params:onCompleteParams});
				return;
			}
			var swfLoader : SWFLoader = ObjectPool.getObject(SWFLoader, lib, onComplete, onCompleteParams);
			swfLoader.resetData(lib, onComplete, onCompleteParams);
			swfLoader.completeFun = completeHandler;
			swfLoader.errorFun = errorHandler;
			_otherLoader[lib.key] = swfLoader;
			_preModel.add(swfLoader);
		}
	}
}