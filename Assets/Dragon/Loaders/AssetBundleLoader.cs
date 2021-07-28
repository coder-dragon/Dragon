using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using Dragon.Logging;
using UnityEngine;

namespace Dragon.Loaders
{
    /// <summary>
    /// 用于加载<see cref="AssetBundle"/>的加载器
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
            _runCoroutine = CoroutineManager.StartCoroutine(loadAssetBundle());
        }

        /// <summary>
        /// 当加载器需要被释放时调用此方法。
        /// </summary>
        protected override void OnDispose()
        {
            if (_dependencyLoaders != null)
            {
                foreach (var dependencyLoader in _dependencyLoaders)
                    AssetLoaderPool.Put(dependencyLoader);
                _dependencyLoaders = null;
            }

            if (_runCoroutine != null)
                CoroutineManager.StopCoroutine(_runCoroutine);

            if (_loadDependcyCoroutine != null)
                CoroutineManager.StopCoroutine(_loadDependcyCoroutine);

            if (_streamAssetBundleLoader != null)
            {
                AssetLoaderPool.Put(_streamAssetBundleLoader);
                _streamAssetBundleLoader = null;
            }

            base.OnDispose();
        }

        private IEnumerator loadAssetBundle()
         {
             _log.Verbose($"开始加载：{Uri}");
             // manifest文件也在bundle中，加载初始manifest时不需要查找依赖
             if (!IgnoreManifest)
             {
                 //manifest文件为同步加载，如果找不到直接跳出协程
                 var manifest = ManifestRepository.Get(Uri);
                 if (manifest == null)
                 {
                     Finish("can not locate manifest for " + Uri, null);
                     yield break;
                 }

                 //开始加载依赖项
                 if (Mode == AssetLoadMode.Sync)
                 {
                     loadDependenciesSync(manifest);
                 }
                 else
                 {
                     _loadDependcyCoroutine = CoroutineManager.StartCoroutine(loadDependenciesAsync(manifest));
                     yield return _loadDependcyCoroutine;
                 }

                 if (Error == null && IsDone)
                 {
                     Finish(Error, Result);
                     yield break;
                 }
             }
             
             //AssetBundle模式下优先从PersistentDataPath下加载
             var path = "assetbundles/" + Uri;
             Stream stream = null;
             if (File.Exists(PathUtility.GetPersistentDataPath(path)))
                 stream = File.Open(PathUtility.GetPersistentDataPath(path), FileMode.Open);
             if (stream == null)
             {
                 Finish($"{path} not exists", null);
                 yield break;
             }

             _streamAssetBundleLoader = AssetLoaderPool.Get<StreamAssetBundleLoader>(Uri);
             _streamAssetBundleLoader.SetStream(stream).SetMode(Mode).FluentStart();
             while (!_streamAssetBundleLoader.IsDone)
             {
                 _createAssetBundleProgress = _streamAssetBundleLoader.Progress * 0.5f + 0.5f;
                 yield return null;
             }

             if (!_streamAssetBundleLoader.IsOk)
             {
                 Finish(_streamAssetBundleLoader.Error, null);
             }

             _createAssetBundleProgress = 1f;
             _log.Verbose($"加载完成：{Uri}");
             Finish(null, _streamAssetBundleLoader.AssetBundle);
         }

         /// <summary>
         /// 同步加载所有<see cref="AssetBundle"/>依赖项
         /// </summary>
         /// <param name="manifest">资源清单列表</param>
         private void loadDependenciesSync(AssetBundleManifest manifest)
         {
             var dependencies = manifest.GetAllDependencies(Uri);
             if (dependencies.Length == 0)
                 return;
             _dependencyLoaders = new List<AssetLoaderBase>(dependencies.Length);
             foreach (var dependency in dependencies)
             {
                 var dependencyLoader = AssetLoaderPool.Get<AssetLoaderBase>(dependency)
                     .AsSync().FluentStart();
                 _dependencyLoaders.Add(dependencyLoader);
             }

             _dependencyLoadingProgress = 1;
         }
         
         /// <summary>
         /// 异步加载所有<see cref="AssetBundle"/>依赖项
         /// </summary>
         /// <param name="manifest">资源清单列表</param>
         private IEnumerator loadDependenciesAsync(AssetBundleManifest manifest)
         {
             var dependencies = manifest.GetAllDependencies(Uri);
             if (dependencies.Length == 0)
                 yield break;
             _dependencyLoaders = new List<AssetLoaderBase>(dependencies.Length);
             foreach (var dependency in dependencies)
             {
                 var dependencyLoader = AssetLoaderPool.Get<AssetLoaderBase>(dependency)
                     .AsSync().FluentStart();
                 _dependencyLoaders.Add(dependencyLoader);
             }

             while (true)
             {
                 updateDepencyLoadingProgress();
                 if(Error != null)
                    break;
                 if (_dependencyLoadingProgress >= 1)
                    break;
                 yield return null;
             }

             _dependencyLoadingProgress = 1;
         }

         /// <summary>
         /// 更新当前依赖项的加载进度
         /// </summary>
         private void updateDepencyLoadingProgress()
         {
             _dependencyLoadingProgress = 0f;
             if(_dependencyLoaders == null)
                 return;
             if (_dependencyLoaders.Count == 0)
             {
                 _dependencyLoadingProgress = 1f;
                 return;
             }

             foreach (var loader in _dependencyLoaders)
             {
                 if (loader.Error != null)
                 {
                     Error = loader.Error;
                     return;
                 }

                 _dependencyLoadingProgress += loader.Progress;
             }

             _dependencyLoadingProgress /= _dependencyLoaders.Count;
         }

        private static IAssetBundleManifestRepository _manifestRepository;
        private float _createAssetBundleProgress;
        private float _dependencyLoadingProgress;
        private List<AssetLoaderBase> _dependencyLoaders;
        private StreamAssetBundleLoader _streamAssetBundleLoader;
        private Coroutine _runCoroutine;
        private Coroutine _loadDependcyCoroutine;
        private static readonly Log _log = LogManager.GetLogger(typeof(AssetBundleLoader));
    }
}