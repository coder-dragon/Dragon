using Dragon.EditorOnly;
using Dragon.LuaExtensions.FileLoaders;
using System;
using System.Diagnostics;
using System.IO;
using UnityEngine;
using XLua;
using XLua.LuaDLL;
using Debug = UnityEngine.Debug;

namespace Dragon
{
    public class XLuaModul : ILuaModul
    {

        public LuaEnv Env { get; private set; }

        #region ILuaModul接口实现

        public event Action Reloading;

        /// <summary>
        /// 执行指定的lua脚本
        /// </summary>
        /// <param name="script"></param>
        /// <returns></returns>
        public object[] DoString(string script)
        {
            return Env.DoString(script);
        }

        /// <summary>
        /// 初始化模块
        /// </summary>
        public void Initialize()
        {
            if (_isInitialized)
                return;
            Env = CreateEnv();
            _require = Env.Global.Get<Func<string, LuaTable>>("require");
            Require("main");
            _isInitialized = true;

        }
        public void Reload()
        {
            UnLoad();
            Initialize();
        }
        public LuaTable Require(string path)
        {
            return _require(path);
        }

        #endregion

        protected virtual LuaEnv CreateEnv()
        {
            LuaEnv env = new LuaEnv();
            // 根据文件目录的Lua脚本加载器
            #if UNITY_EDITOR
            env.AddLoader(new FromDirectory(ProjectPath.Get("Assets/Lua")).ReadFile);
            #else
            env.AddLoader(new FromDirectory(PathUtility.GetPersistentDataPath("lua")).ReadFile);
            #endif
            return env;
        }

        public void UnLoad()
        {
            if (Env == null)
                return;
            if (Reloading != null)
            {
                foreach (var handler in Reloading.GetInvocationList())
                {
                    var action = (Action)handler;
                    try
                    {
                        action();
                    }
                    catch (Exception e)
                    {
                        Debug.LogError($"[XLuaModule]reloading event handler exception:{e}");
                    }
                }
            }
        }

        private bool _isInitialized;
        private Func<string, LuaTable> _require;
    }
}