using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Dragon.MonoEventListeners
{
    /// <summary>
    /// 提供App生命周期的注入
    /// </summary>
    public class App : MonoBehaviour
    {
        public event BooleanEventHandler OnApplicationFoucsEvent;
        public event BooleanEventHandler OnApplicationFoucsPauseEvent;
        public event EventHandler OnApplicationFoucsQuitEvent;

        public static App Get(GameObject go)
        {
            return go.GetOrAddComponent<App>();
        }

        private void OnApplicationFocus(bool focus)
        {
            OnApplicationFoucsEvent?.Invoke(gameObject, focus);
        }

        private void OnApplicationPause(bool pause)
        {
            OnApplicationFoucsPauseEvent?.Invoke(gameObject, pause);
        }

        private void OnApplicationQuit()
        {
            OnApplicationFoucsQuitEvent?.Invoke(gameObject);
        }
    }
}

