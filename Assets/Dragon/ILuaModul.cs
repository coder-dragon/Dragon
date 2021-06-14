using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;

namespace Dragon
{
    /// <summary>
    /// lua模块接口
    /// </summary>
    public interface ILuaModul
    {
        /// <summary>
        /// 当lua模块进行重载时触发事件
        /// </summary>
        event Action Reloading;

        /// <summary>
        /// 执行指定的lua脚本
        /// </summary>
        /// <param name="script"></param>
        /// <returns></returns>
        object[] DoString(string script);

        /// <summary>
        /// 初始化模块
        /// </summary>
        void Initialize();

        /// <summary>
        /// 重新载入lua环境
        /// </summary>
        void Reload();

        /// <summary>
        /// 加载指定路径的lua脚本
        /// </summary>
        /// <param name="path"></param>
        /// <returns></returns>
        LuaTable Require(string path);
    }
}