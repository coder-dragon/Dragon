using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Dragon.MonoEventListeners
{
    /// <summary>
    /// 提供<see cref="GameObject"/>生命周期的注入
    /// </summary>
    public class Lifecycle : MonoBehaviour
    {
        public event EventHandler FixedUpdateEvent;

        public event EventHandler LateUpdateEvent;

        public event EventHandler OnDestroyEvent;

        public event EventHandler OnDisableEvent;

        public event EventHandler OnEnableEvent;

        public event EventHandler StartEvent;

        public event EventHandler UpdateEvent;

        public static Lifecycle Get(GameObject obj)
        {
            return obj.GetOrAddComponent<Lifecycle>();
        }

        private void FixedUpdate()
        {
            FixedUpdateEvent?.Invoke(gameObject);
        }

        private void LateUpdate()
        {
            LateUpdateEvent?.Invoke(gameObject);
        }

        private void OnDestroy()
        {
            OnDestroyEvent?.Invoke(gameObject);
        }

        private void OnDisable()
        {
            OnDisableEvent?.Invoke(gameObject);
        }

        private void OnEnable()
        {
            OnEnableEvent?.Invoke(gameObject);
        }

        private void Start()
        {
            StartEvent?.Invoke(gameObject);
        }

        private void Update()
        {
            UpdateEvent?.Invoke(gameObject);
        }
    }
}

