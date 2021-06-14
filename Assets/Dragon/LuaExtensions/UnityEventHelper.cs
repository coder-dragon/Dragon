using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;

namespace Dragon.LuaExtensions
{
    /// <summary>
    /// 为lua环境提供
    /// </summary>
    public class UnityEventHelper : MonoBehaviour
    {
        /// <summary>
        /// 初始化
        /// </summary>
        /// <param name="luaTable"></param>
        public void Initialize(LuaTable luaTable)
        {

        }

        private void Update()
        {
            
        }

        private void FixedUpdate()
        {
            
        }

        private void LateUpdate()
        {
            
        }

        private void OnApplicationPause(bool pause)
        {
            
        }

        private void OnApplicationFocus(bool focus)
        {
            
        }

        private void OnApplicationQuit()
        {
            
        }

        private void OnDestroy()
        {
            clearup();
        }

        private void clearup()
        {
            _update = null;
            _fixedUpdate = null;
            _lateUpdate = null;
            _onApplicationPause = null;
            _onApplicationFoucs = null;
            _onApplicationQuit = null;
        }

        private Action _update;
        private Action _fixedUpdate;
        private Action _lateUpdate;
        private Action _onApplicationPause;
        private Action _onApplicationFoucs;
        private Action _onApplicationQuit;

    }
}

