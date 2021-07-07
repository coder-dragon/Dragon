using Dragon.EditorOnly;
using Dragon.LuaExtensions.FileLoaders;
using System;
using System.Collections;
using System.Diagnostics;
using System.IO;
using Dragon.Logging;
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

            if (_tickCoroutine == null)
                _tickCoroutine = CoroutineManager.StartCoroutine(tick());
        }
        public void Reload()
        {
            Unload();
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

        /// <summary>
        /// 释放LuaEnv
        /// </summary>
        public void Unload()
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

            _require = null;
            CoroutineManager.StartCoroutine(disposeEnv(Env));
            Env = null;
            _isInitialized = false;
        }

        /// <summary>
        /// 释放LuaEnv以及一些异常处理
        /// </summary>
        /// <param name="env">lua env</param>
        /// <returns></returns>
        private static IEnumerator disposeEnv(LuaEnv env)
        {
            yield return null;
            var beginTime = Time.realtimeSinceStartup;
            try
            {
                env.Dispose();
                _log.Info($"释放LuaEnv成功，耗时: {Time.realtimeSinceStartup-beginTime}");
                yield break;
            }
            catch (Exception e)
            {
            }

            // 直接env.Dispose()的情况下可能是无法释放掉lua环境的
            // 此可能一些游戏对象和委托没有销毁和置空，但这是需要时间的
            // 所以需要每秒循环进行释放
            var max = 10f;
            while (Time.realtimeSinceStartup - beginTime < max)
            {
                yield return new WaitForSeconds(1);
                env.Tick();
                if (env.translator.AllDelegateBridgeReleased())
                {
                    beginTime = Time.realtimeSinceStartup;
                    env.Dispose();
                    _log.Info($"释放LuaEnv成功，耗时: {Time.realtimeSinceStartup-beginTime}");
                    yield break;
                }
            }
            _log.Warn("释放LuaEnv失败，请检查C#委托是否没有释放，或者加上[CSharpCallLua]标签");
        }
        
        /// <summary>
        /// LuaEnv 定时GC函数
        /// </summary>
        /// <returns></returns>
        private IEnumerator tick()
        {
            while (true)
            {
                Env?.Tick();
                yield return null;
            }
        }

        private bool _isInitialized;
        private Coroutine _tickCoroutine;
        private Func<string, LuaTable> _require;
        private static Log _log = LogManager.GetLogger(typeof(XLuaModul));
    }
}