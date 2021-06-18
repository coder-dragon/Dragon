using System;
using System.Collections;
using System.Collections.Generic;
using Dragon.Logging;
using UnityEngine;

namespace Dragon.Loaders
{
    /// <summary>
    ///     /// <summary>
    /// 用于加载<see cref="AssetBundle"/>的加载器
    /// </summary>
    /// </summary>
    public class AssetBundleLoader : AssetLoaderBase
    {
        /// <summary>
        /// 获取或者设置获取<see cref="AssetBundleManifest"/>的仓库
        /// </summary>
        /// <exception cref="ArgumentException"></exception>
        public static IAssetBundleManifestRepository ManifestRepository
        {
            get
            {
                if (_manifestRepository == null)
                    _manifestRepository = new AssetBundleManifestRepository();
                return _manifestRepository;
            }
            set
            {
                if (value == null)
                    throw new ArgumentException(nameof(value));
                _manifestRepository = value;
            }
        }

        /// <summary>
        /// 获取加载完成的AssetBundle
        /// </summary>
        public AssetBundle AssetBundle => (AssetBundle) Result;

        /// <summary>
        /// 获取或设置一个值，表示是否在加载的时候忽略资源清单
        /// </summary>
        public bool IgnoreManifest { get; set; }

        /// <summary>
        /// 获取加载进度
        /// </summary>
        public override float Progress
        {
            get
            {
                if (_dependencyLoaders == null)
                    return _createAssetBundleProgress;
                return (_createAssetBundleProgress + _dependencyLoadingProgress) / 2;
            }
        }

        protected override void OnStart()
        {
            //_runCoroutine = CoroutineManager.StartCoroutine(run());
        }
        //TODO:ab包加载逻辑
        // private IEnumerator run()
        // {
        //     _log.Verbose($"开始加载：{Uri}");
        //     if (!IgnoreManifest)
        //     {
        //         var manifest = ManifestRepository.Get(Uri);
        //     }
        // }

        private static IAssetBundleManifestRepository _manifestRepository;
        private float _createAssetBundleProgress;
        private float _dependencyLoadingProgress;
        private List<AssetLoaderBase> _dependencyLoaders;
        private Coroutine _runCoroutine;
        private Coroutine _loadDependcyCoroutine;
        private static readonly Log _log = LogManager.GetLogger(typeof(AssetBundleLoader));
    }
}