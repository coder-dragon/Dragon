using Dragon.Logging;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

namespace Dragon.Loaders
{
    /// <summary>
    /// 资源加载器抽象基类
    /// </summary>
    public class AssetLoaderBase : IAssetLoader
    {
        /// <summary>
        /// 获取错误信息。
        /// </summary>
        public string Error { get; protected set; }

        /// <summary>
        /// 获取一个值，表示加载任务是否已经结束。
        /// </summary>
        public bool IsDone { get; protected set; }

        /// <summary>
        /// 获取一个值，表示加载器是否加载成功。
        /// </summary>
        public bool IsOk => Error == null && Result != null;

        /// <summary>
        /// 获取加载进度。
        /// </summary>
        public virtual float Progress { get; private set; }

        /// <summary>
        /// 获取加载的结果。
        /// </summary>
        public object Result { get; private set; }

        /// <summary>
        /// 获取资源定位标识符。
        /// </summary>
        public string Uri { get; private set; }

        public AssetLoadMode Mode
        {
            get { return _mode;}
            set
            {
                if (_mode == value)
                    return;

            }
        }

        /// <summary>
        /// 获取一个值，表示加载器是否已经启动
        /// </summary>
        public bool IsStarted { get; private set; }

        /// <summary>
        /// 获取一个值，表示加载器是否已经释放
        /// </summary>
        public bool IsDisposed { get; private set; }

        /// <summary>
        /// 获取一个值，表示加载器是否已准备好被释放。
        /// </summary>
        public bool IsReadyForDispose => RefCount == 0 && !_isResurrected;

        /// <summary>
        /// 获取加载器的引用计数
        /// </summary>
        public int RefCount
        {
            get { return _refCount; }
            set
            {
                _refCount = value;
                if (_refCount < 0)
                    _log.Warn($"[{GetType().Name}]资源引用计数异常 {Uri} 当前计数：{RefCount}");
            }
        }

        /// <summary>
        /// 启动加载器
        /// </summary>
        public void Start()
        {
            _isResurrected = false;
            // 已加载资源成功，直接返回
            if (IsDone)
            {
                _finishCallbacks.ForEach((cb) => cb.DynamicInvoke(this));
                return;
            }
            if (IsStarted)
                return;
            IsStarted = true;
            OnStart();
        }

        protected void Finish(string error, object result)
        {
            Error = error;
            Result = result;
            IsDone = true;
            Progress = 1;
            _finishCallbacks.ForEach((cb) => cb.DynamicInvoke(this));
        }

        /// <summary>
        /// 释放加载器所占用的资源
        /// </summary>
        /// <param name="force">是否强制释放</param>
        public void Dispose(bool force = false)
        {
            if (IsDisposed)
                return;
            OnDispose();
            IsDisposed = true;
        }

        /// <summary>
        /// 当加载器启动时调用此方法
        /// </summary>
        protected virtual void OnStart()
        {

        }

        /// <summary>
        /// 当加载器需要被释放时调用此方法
        /// </summary>
        protected virtual void OnDispose()
        {
            Error = null;
            Result = null;
            IsDone = false;
            Progress = 0;
        }

        /// <summary>
        /// 增加一个加载完成的回调。
        /// </summary>
        /// <param name="callback">回调</param>
        public void AddFinishCallback<T>(AssetLoaderFinishCallback<T> callback) where T : AssetLoaderBase
        {
            _finishCallbacks.Add(callback);
        }

        /// <summary>
        /// 增加一个加载完成的回调。
        /// </summary>
        /// <param name="callback">回调</param>
        public void AddFinishCallback(AssetLoaderFinishCallback callback)
        {
            _finishCallbacks.Add(callback);
        }

        /// <summary>
        /// 移除一个加载完成的回调。
        /// </summary>
        /// <param name="callback">回调</param>
        public void RemoveFinishCallback<T>(AssetLoaderFinishCallback<T> callback) where T : AssetLoaderBase
        {
            _finishCallbacks.Remove(callback);
        }

        /// <summary>
        /// 移除一个加载完成的回调。
        /// </summary>
        /// <param name="callback">回调</param>
        public void RemoveFinishCallback(AssetLoaderFinishCallback callback)
        {
            _finishCallbacks.Remove(callback);
        }

        #region IPoolable Members
        public void OnGet() { }

        public void OnPut() { }
        #endregion

        #region Call by AssetLoaderPool
        /// <summary>
        /// 标记一个状态，表示当前资源加载器不在池中，但是未被使用
        /// </summary>
        public void Resurrect()
        {
            _isResurrected = true;
        }

        /// <summary>
        /// 从池中创建该加载器对象，该方法由池调用。
        /// </summary>
        public void CreateFromPool(string uri)
        {
            Uri = uri;
            RefCount++;
        }

        public void GetFromPool()
        {
            RefCount++;
            OnGet();
        }

        /// <summary>
        /// 将该加载器回收到池中，该方法由池调用。
        /// </summary>
        public void ReturnToPool()
        {
            RefCount--;
            OnPut();
        }

        #endregion

        private int _refCount;
        private bool _isResurrected;
        private AssetLoadMode _mode;
        private readonly List<Delegate> _finishCallbacks = new List<Delegate>();
        private static readonly Log _log = LogManager.GetLogger(typeof(AssetLoaderBase));
    }
}
