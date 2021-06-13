using Dragon.Logging;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

namespace Dragon.Loaders
{
    /// <summary>
    /// ��Դ�������������
    /// </summary>
    public class AssetLoaderBase : IAssetLoader
    {
        /// <summary>
        /// ��ȡ������Ϣ��
        /// </summary>
        public string Error { get; protected set; }

        /// <summary>
        /// ��ȡһ��ֵ����ʾ���������Ƿ��Ѿ�������
        /// </summary>
        public bool IsDone { get; protected set; }

        /// <summary>
        /// ��ȡһ��ֵ����ʾ�������Ƿ���سɹ���
        /// </summary>
        public bool IsOk => Error == null && Result != null;

        /// <summary>
        /// ��ȡ���ؽ��ȡ�
        /// </summary>
        public virtual float Progress { get; private set; }

        /// <summary>
        /// ��ȡ���صĽ����
        /// </summary>
        public object Result { get; private set; }

        /// <summary>
        /// ��ȡ��Դ��λ��ʶ����
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
        /// ��ȡһ��ֵ����ʾ�������Ƿ��Ѿ�����
        /// </summary>
        public bool IsStarted { get; private set; }

        /// <summary>
        /// ��ȡһ��ֵ����ʾ�������Ƿ��Ѿ��ͷ�
        /// </summary>
        public bool IsDisposed { get; private set; }

        /// <summary>
        /// ��ȡһ��ֵ����ʾ�������Ƿ���׼���ñ��ͷš�
        /// </summary>
        public bool IsReadyForDispose => RefCount == 0 && !_isResurrected;

        /// <summary>
        /// ��ȡ�����������ü���
        /// </summary>
        public int RefCount
        {
            get { return _refCount; }
            set
            {
                _refCount = value;
                if (_refCount < 0)
                    _log.Warn($"[{GetType().Name}]��Դ���ü����쳣 {Uri} ��ǰ������{RefCount}");
            }
        }

        /// <summary>
        /// ����������
        /// </summary>
        public void Start()
        {
            _isResurrected = false;
            // �Ѽ�����Դ�ɹ���ֱ�ӷ���
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
        /// �ͷż�������ռ�õ���Դ
        /// </summary>
        /// <param name="force">�Ƿ�ǿ���ͷ�</param>
        public void Dispose(bool force = false)
        {
            if (IsDisposed)
                return;
            OnDispose();
            IsDisposed = true;
        }

        /// <summary>
        /// ������������ʱ���ô˷���
        /// </summary>
        protected virtual void OnStart()
        {

        }

        /// <summary>
        /// ����������Ҫ���ͷ�ʱ���ô˷���
        /// </summary>
        protected virtual void OnDispose()
        {
            Error = null;
            Result = null;
            IsDone = false;
            Progress = 0;
        }

        /// <summary>
        /// ����һ��������ɵĻص���
        /// </summary>
        /// <param name="callback">�ص�</param>
        public void AddFinishCallback<T>(AssetLoaderFinishCallback<T> callback) where T : AssetLoaderBase
        {
            _finishCallbacks.Add(callback);
        }

        /// <summary>
        /// ����һ��������ɵĻص���
        /// </summary>
        /// <param name="callback">�ص�</param>
        public void AddFinishCallback(AssetLoaderFinishCallback callback)
        {
            _finishCallbacks.Add(callback);
        }

        /// <summary>
        /// �Ƴ�һ��������ɵĻص���
        /// </summary>
        /// <param name="callback">�ص�</param>
        public void RemoveFinishCallback<T>(AssetLoaderFinishCallback<T> callback) where T : AssetLoaderBase
        {
            _finishCallbacks.Remove(callback);
        }

        /// <summary>
        /// �Ƴ�һ��������ɵĻص���
        /// </summary>
        /// <param name="callback">�ص�</param>
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
        /// ���һ��״̬����ʾ��ǰ��Դ���������ڳ��У�����δ��ʹ��
        /// </summary>
        public void Resurrect()
        {
            _isResurrected = true;
        }

        /// <summary>
        /// �ӳ��д����ü��������󣬸÷����ɳص��á�
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
        /// ���ü��������յ����У��÷����ɳص��á�
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
