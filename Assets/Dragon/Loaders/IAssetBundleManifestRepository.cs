using UnityEngine;

namespace Dragon.Loaders
{
    /// <summary>
    /// <see cref="AssetBundleManifest"/>仓库接口，支持多个manifest的特性
    /// </summary>
    public interface IAssetBundleManifestRepository
    {
        /// <summary>
        /// 获取指定位置的<see cref="AssetBundleManifest"/>>
        /// </summary>
        /// <param name="uri">统一资源标识符</param>
        /// <returns>资源清单文件</returns>
        AssetBundleManifest Get(string uri);

        /// <summary>
        /// 重置仓库缓存，当清单文件被重写时调用
        /// </summary>
        void Invalidate();
    }
}