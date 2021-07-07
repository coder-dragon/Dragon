using Dragon;
using Dragon.LuaExtensions;
using Dragon.Pooling;
using System;
using System.Collections.Generic;
using System.Net.Mime;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Events;
using XLua;

namespace Dragon.Editor.LuaExtensions
{
    /// <summary>
    /// XLua导出配置
    /// </summary>
    public static class XLuaExportSetting
    {
        /// <summary>
        /// 黑名单
        /// </summary>
        [BlackList]
        public static List<List<string>> BlackList = new List<List<string>>();

        /// <summary>
        /// C#静态调用Lua(包括事件的原型)，仅支持配置delegate，interface
        /// </summary>
        [CSharpCallLua]
        public static List<Type> CSharpCallLua = new List<Type>()
        {
            // 委托类型
            typeof(Dragon.MonoEventListeners.EventHandler),
            typeof(Dragon.MonoEventListeners.BooleanEventHandler)
        };

        /// <summary>
        /// Lua中使用C#的库的配置
        /// </summary>
        [LuaCallCSharp]
        public static List<Type> LuaCallCSharp = new List<Type>
        {
            #region Dragon
            // C#类型
            typeof(LuaInjection),
            typeof(GameObjectPool),
            typeof(UnityEngineObjectExtention),
            typeof(GameObjectExtenstion),
            #endregion
            
            #region UGUI
            typeof (Rect),
            typeof (Canvas),
            typeof (CanvasGroup),
            typeof (UnityEventBase),
            typeof (UnityEvent),
            typeof (RectTransform),
            typeof (MediaTypeNames.Text),
            typeof (Image),
            typeof (RawImage),
            typeof (Button),
            typeof (Button.ButtonClickedEvent),
            typeof (ToggleGroup),
            typeof (Toggle),
            typeof (Toggle.ToggleEvent),
            typeof (ScrollRect),
            typeof (ScrollRect.ScrollRectEvent),
            typeof (Slider),
            typeof (Slider.SliderEvent),
            typeof (InputField),
            typeof (InputField.OnChangeEvent),
            typeof (InputField.SubmitEvent),
            typeof (Dropdown),
            typeof (Dropdown.DropdownEvent),
            #endregion
        };
    }
}
