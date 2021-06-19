using System;
using System.Collections;
using System.IO;
using UnityEngine;
using Dragon.Logging;

namespace Dragon.Loaders
{
    /// <summary>
    /// 从流中加载<see cref="AssetBundle"/>资源包
    /// </summary>
    public class StreamAssetBundleLoader : AssetLoaderBase
    {
        /// <summary>
        /// 获取加载完成的AssetBundle
        /// </summary>
        public AssetBundle AssetBundle => (AssetBundle) Result;

        /// <summary>
        /// 获取加载进度。
        /// </summary>
        public override float Progress
        {
            get
            {
                if (_createRequest == null)
                    return 0;
                return _createRequest.progress;
            }
        }

        /// <summary>
        /// 设置加载资源需要的流
        /// </summary>
        /// <param name="stream">流文件</param>
        /// <returns>自身</returns>
        public StreamAssetBundleLoader SetStream(Stream stream)
        {
            _stream = stream;
            return this;
        }
        
        protected override void OnStart()
        {
            switch (Mode)
            {
                case AssetLoadMode.Async:
                    _createRequest = AssetBundle.LoadFromStreamAsync(_stream);
                    if (_createRequest == null)
                    {
                        _log.Error("create from stream failed "+ Uri);
                        Finish("create from stream failed", null);
                        return;
                    }
                    _runner = CoroutineManager.StartCoroutine(loadAsync(_createRequest));
                    break;
                case AssetLoadMode.Sync:
                    Finish(null,AssetBundle.LoadFromStream(_stream));
                    break;
                default:
                    throw new ArgumentOutOfRangeException();
            }
        }

        private IEnumerator loadAsync(AssetBundleCreateRequest req)
        {
            if (!req.isDone)
                yield return null;
            Finish(null, req.assetBundle);
        }

        /// <summary>
        /// 注意！ 这里释放<see cref="AssetBundle"/>和所有引用他的资源
        /// </summary>
        protected override void OnDispose()
        {
            if (_runner != null)
            {
                CoroutineManager.StopCoroutine(_runner);
                _runner = null;
            } 
            if (AssetBundle != null)
            {
                _log.Verbose("unloading assetbundle -> " + AssetBundle);
                AssetBundle.Unload(true);
            }

            _stream = null;
            base.OnDispose();
        }

        private Stream _stream;
        private Coroutine _runner;
        private AssetBundleCreateRequest _createRequest;
        private static readonly Log _log = LogManager.GetLogger(typeof(StreamAssetBundleLoader));
    }
}