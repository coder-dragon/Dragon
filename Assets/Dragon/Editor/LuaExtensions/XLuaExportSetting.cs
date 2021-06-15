using Dragon;
using Dragon.LuaExtensions;
using System;
using System.Collections.Generic;
using Dragon.Pooling;
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
        public static List<Type> CSharpCallLua = new List<Type>();

        /// <summary>
        /// Lua中使用C#的库的配置
        /// </summary>
        [LuaCallCSharp]
        public static List<Type> LuaCallCSharp = new List<Type>
        {
            #region Dragon
            typeof(LuaInjection),
            typeof(GameObjectPool),
            typeof(GameObjectExtenstion)
            #endregion
        };
    }
}
