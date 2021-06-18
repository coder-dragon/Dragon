using UnityEngine;

namespace Dragon.Loaders
{
    /// <summary>
    /// 默认的资源仓库清单
    /// </summary>
    public class AssetBundleManifestRepository : IAssetBundleManifestRepository
    {
        /// <summary>
        /// 获取或者设置默认的Manifest的文件名
        /// </summary>
        public static string ManifestFileName = "manifest.b";
        
        /// <summary>
        /// 获取指定位置的<see cref="AssetBundleManifest"/>>
        /// </summary>
        /// <param name="uri">统一资源标识符</param>
        /// <returns>资源清单文件</returns>
        public AssetBundleManifest Get(string uri)
        {
            if (_cachedManifest == null)
            {
                var manifestLoader = AssetLoaderPool.Get<AssetBundleManifestLoader>(ManifestFileName)
                    .AsSync().FluentStart();
                _cachedManifest = manifestLoader.Manifest;
                AssetLoaderPool.Put(manifestLoader);
            }

            return _cachedManifest;
        }

        public void Invalidate()
        {
            _cachedManifest = null;
        }

        private AssetBundleManifest _cachedManifest;
    }
}