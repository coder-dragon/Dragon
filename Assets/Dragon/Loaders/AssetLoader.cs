using Dragon.Logging;
using System;
using System.Collections;
using UnityEngine;

namespace Dragon.Loaders
{
    class AssetLoader : AssetLoaderBase
    {
        /// <summary>
        /// 获取需要加载的资源名
        /// </summary>
        public string AssetName { get; private set; }

        /// <summary>
        /// 获取需要加载的资源类型
        /// </summary>
        public Type AssetType { get; private set; }
        
        /// <summary>
        /// 获取需要加载的AssetBundle包名
        /// </summary>
        public string AssetBundleName { get; private set; }

        /// <summary>
        /// 获取加载进度。
        /// </summary>
        public override float Progress => (_assetLoadingProgress + _assetBundleLoadingProgress) / 2;

        protected override void OnDispose()
        {
            if (_assetBundleLoader != null)
                AssetLoaderPool.Put(_assetBundleLoader);
            base.OnDispose();
        }
        
        protected override void OnStart()
        {
            base.OnStart();
            var array = Uri.Split(':');
            AssetBundleName = array[0];
            AssetName = array[1];
            if (array.Length > 2)
            {
                AssetType = Type.GetType(array[2]);
                if (AssetType == null)
                    _log.Warn("[AssetLoader]Invalid asset type -> " + array[2]);
            }
            else
            {
                AssetType = typeof(UnityEngine.Object);
            }
            //编辑器模式从项目工程中加载，真机从assetbundle中加载
#if UNITY_EDITOR
            CoroutineManager.StartCoroutine(loadFromEdtior());
#else
            loadFromAssetBundle(loadFromAssetBundle());
#endif
        }

         private IEnumerator loadFromAssetBundle()
         {
             _log.Verbose($"开始加载:{Uri}");
             _assetBundleLoader = AssetLoaderPool.Get<AssetBundleLoader>(AssetBundleName)
                 .SetMode(Mode).FluentStart();
             while (!_assetBundleLoader.IsDone)
             {
                 _assetBundleLoadingProgress = _assetBundleLoader.Progress;
                 yield return null;
             }

             if (_assetBundleLoader.Error != null)
             {
                 Finish(_assetBundleLoader.Error, null);
                 yield break;
             }

             if (_assetBundleLoader.AssetBundle == null)
             {
                 Finish($"assetbundle not exists {Uri}", null);
                 yield break;
             }

             _assetBundleLoadingProgress = 1;

             switch (Mode)
             {
                 case AssetLoadMode.Sync:
                     var asset = _assetBundleLoader.AssetBundle.LoadAsset(AssetName, AssetType);
                     Finish(null, asset);
                     break;
                 case AssetLoadMode.Async:
                     var request = _assetBundleLoader.AssetBundle.LoadAssetAsync(AssetName, AssetType);
                     while (!request.isDone)
                    {
                        _assetLoadingProgress = request.progress;
                        yield return null;
                    }
                    if (request.asset != null) 
                    {
                        Finish($"asset not exists in assetbundle {Uri}", null);
                        break; 
                    } 
                     _assetLoadingProgress = 1f; 
                     Finish(null, request.asset);
                     break;
                 default:
                     throw new ArgumentException();
             }
         }

#if UNITY_EDITOR
        private IEnumerator loadFromEdtior()
        {
            var assetPaths = UnityEditor.AssetDatabase.GetAssetPathsFromAssetBundleAndAssetName(AssetBundleName, AssetName);
            for (int index = 0; index < assetPaths.Length; index++)
            {
                var assetPath = assetPaths[index];
                var result = UnityEditor.AssetDatabase.LoadAssetAtPath(assetPath, AssetType);
                if(result != null)
                {
                    Finish(null, result);
                    yield break;
                }
            }
            Finish($"从编辑器加载资源失败 AssetName = {AssetName} AssetType = {AssetType} AssetBundleName = {AssetBundleName}", null);
        }
#endif
        private AssetBundleLoader _assetBundleLoader;
        private float _assetBundleLoadingProgress;
        private float _assetLoadingProgress;
        private static Log _log = LogManager.GetLogger(typeof(AssetLoader));
    }
}