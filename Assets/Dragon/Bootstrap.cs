using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua.LuaDLL;

namespace Dragon
{
    /// <summary>
    /// 用于引导游戏启动
    /// </summary>
    public class Bootstrap : MonoBehaviour
    {
        /// <summary>
        /// 获取<see cref="Bootstrap"/>的唯一实例
        /// </summary>
        public static Bootstrap Instance { get; private set; }

        public virtual ILuaModul LuaModule
        {
            get
            {
                if (_luaModel == null)
                    _luaModel = new XLuaModul();
                return _luaModel;
            }
        }

        protected void Awake()
        {
            Instance = this;
        }

        public void Start()
        {
            if (_isStarted)
                return;
            OnStartup();
            _isStarted = true;
        }

        protected void OnDestroy()
        {
            OnShutdown();
        }

        /// <summary>
        /// 引导游戏启动
        /// </summary>
        protected virtual void OnStartup()
        {
            initLuaModule();
        }

        /// <summary>
        /// 当引导关闭时调用此方法。
        /// </summary>
        protected virtual void OnShutdown()
        {

        }

        private void initLuaModule()
        {
            try
            {
                LuaModule.Initialize();
            }
            catch (Exception e)
            {
                throw e;
            }
        }

        private bool _isStarted = false;
        private ILuaModul _luaModel;
    }

}