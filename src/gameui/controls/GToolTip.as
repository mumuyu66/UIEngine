package gameui.controls
{
	import gameui.core.GComponent;
	import gameui.data.GToolTipData;
	import gameui.manager.UIManager;

	import flash.display.Sprite;


	/**
	 * Game ToolTip
	 * 
	 */
	public class GToolTip extends GComponent {
		protected var _data : GToolTipData;
		protected var _backgroundSkin : Sprite;
		protected var _label : GLabel;

		override protected function create() : void {
			_backgroundSkin = UIManager.getUI(_data.backgroundAsset);
			addChild(_backgroundSkin);
			_label = new GLabel(_data.labelData);
			_label.x = _label.y = _data.padding;
			addChild(_label);
		}

		override protected function layout() : void {
			_width = _label.width + _data.padding * 2;
			_height = _label.height + _data.padding * 2;
			_backgroundSkin.width = _width;
			_backgroundSkin.height = _height;
		}

		public function GToolTip(data : GToolTipData) {
			_data = data;
			super(data);
			mouseEnabled = mouseChildren = false;
		}

		public function get data() : GToolTipData {
			return _data;
		}

		public function get text() : String {
			return _label.text;
		}

		override public function set source(value : *) : void {
			if (value == null) {
				_label.clear();
			} else {
				_label.htmlText = String(value);
				layout();
			}
			_source = value;
		}
	}
}