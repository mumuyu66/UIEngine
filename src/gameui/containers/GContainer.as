package gameui.containers {
	import gameui.core.GAlign;
	import gameui.core.GComponent;
	import gameui.layout.GLayout;
	import gameui.manager.UIManager;

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	/**
	 * @author yangyiqiang
	 */
	public class GContainer extends Sprite {
		protected var _source : *;

		private function addToStageHandler(event : Event) : void {
			onShow();
		}

		private function removeFromStageHandler(event : Event) : void {
			onHide();
		}

		private function onFocusIn(event : Event) : void {
			addChildAt(event.currentTarget as DisplayObject, this.numChildren == 0 ? 0 : (numChildren - 1));
		}

		protected function onShow() : void {
		}

		protected function onHide() : void {
		}

		protected function swap(source : Sprite, target : Sprite) : Sprite {
			if (source == null || source.parent == null || target == null || source == target) {
				return source;
			}
			var index : int = source.parent.getChildIndex(source);
			var parent : DisplayObjectContainer = source.parent;
			source.parent.removeChild(source);
			parent.addChildAt(target, index);
			return target;
		}

		override public function addChild(child : DisplayObject) : DisplayObject {
			if (!child) return child;
			if (child is GTitleWindow)
				child.addEventListener(MouseEvent.MOUSE_DOWN, onFocusIn);
			return super.addChild(child);
		}

		override public function addChildAt(child : DisplayObject, index : int) : DisplayObject {
			if (!child) return child;
			child.addEventListener(MouseEvent.MOUSE_DOWN, onFocusIn);
			return super.addChildAt(child, index);
		}

		override public function removeChild(child : DisplayObject) : DisplayObject {
			if (!child) return child;
			child.removeEventListener(MouseEvent.MOUSE_DOWN, onFocusIn);
			return super.removeChild(child);
		}

		override public function removeChildAt(index : int) : DisplayObject {
			var child : DisplayObject = getChildAt(index);
			if (!child) return child;
			child.removeEventListener(MouseEvent.MOUSE_DOWN, onFocusIn);
			return super.removeChildAt(index);
		}

		public function GContainer() {
			addEventListener(Event.ADDED_TO_STAGE, addToStageHandler);
			addEventListener(Event.REMOVED_FROM_STAGE, removeFromStageHandler);
		}

		public  function stageResizeHandler() : void {
			for (var i : int = 0;i < numChildren;i++) {
				var child : DisplayObject = getChildAt(i);
				var component : GComponent = child as GComponent;
				if (component == null) continue;
				if (component.name == "MenuView") {
					component.x = UIManager.root.stage.stageWidth - component.width;
					component.y = UIManager.root.stage.stageHeight - component.height;
					continue;
				}
				if (component is GTitleWindow) {
					var titleWindow : GTitleWindow = component as GTitleWindow;
					if (titleWindow.modal) titleWindow.resizeModal();
					GLayout.layout(component, new GAlign(titleWindow.x, -1, titleWindow.y));
				}
				if (component.align == null) continue;
				if (component is GPanel) {
					var panel : GPanel = component as GPanel;
					if (panel.modal) panel.resizeModal();
				}
				GLayout.update(UIManager.root, component);
			}
		}

		public function initialization() : void {
		}

		public function set source(value : *) : void {
			_source = value;
		}

		public function get source() : * {
			return _source;
		}
	}
}
