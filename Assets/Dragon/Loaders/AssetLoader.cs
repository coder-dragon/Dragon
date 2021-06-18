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

        public string AssetBundleName { get; private set; }

        /// <summary>
        /// 获取加载进度。
        /// </summary>
        //public override float Progress { get; private set; }

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
            
#if UNITY_EDITOR
            CoroutineManager.StartCoroutine(loadFromEdtior());
#else
#endif
        }
        //TODO:ab包加载逻辑
        // private IEnumerator loadFromAssetBundle()
        // {
        //     _log.Verbose($"开始加载:{Uri}");
        //     
        // }

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

        private static Log _log = LogManager.GetLogger(typeof(AssetLoader));
    }
}