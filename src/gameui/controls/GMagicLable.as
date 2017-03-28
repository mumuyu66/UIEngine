package gameui.controls
{
	import gameui.data.GLabelData;

	import com.greensock.TweenLite;
	import com.greensock.easing.Elastic;

	/**
	 * @author yangyiqiang
	 */
	public class GMagicLable extends GLabel
	{
		public function GMagicLable(data : GLabelData)
		{
			super(data);
		}

		private var _num : Number;

		private var _str : String;

		public function setMagicText(value : String, num : Number, showMagic : Boolean = true) : void
		{
			if (!showMagic)
			{
				_num = num;
				_str = value;
				end();
				return;
			}
			if (_num == num) return;
			if (_num - num > 0)
			{
				_textField.textColor = 0x00ffff;
				TweenLite.to(_textField, 0.6, {alpha:1, textColor:0x000000, overwrite:0, ease:Elastic.easeIn, onComplete:end});
			}
			else
			{
				_textField.textColor = 0xffffff;
				TweenLite.to(_textField, 0.6, {alpha:1, textColor:0x0000ff, overwrite:0, ease:Elastic.easeIn, onComplete:end});
			}
			_num = num;
			_str = value;
		}
		
		public function set num(value:int):void
		{
			_num=value;
		}

		private function end() : void
		{
			_textField.textColor = _data.textColor;
			_textField.text = _str;
			layout();
		}
	}
}
