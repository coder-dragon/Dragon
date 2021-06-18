using UnityEngine;

namespace Dragon.Loaders
{
    /// <summary>
    /// 用于加载<see cref="AssetBundleManifest"/>的加载器
    /// </summary>
    public class AssetBundleManifestLoader : AssetLoaderBase
    {
        /// <summary>
        /// 获取加载成功的<see cref="AssetBundleManifest"/>
        /// </summary>
        public AssetBundleManifest Manifest => Result as AssetBundleManifest;

        protected override void OnStart()
        {
            var loader = AssetLoaderPool.Get<AssetBundleLoader>(Uri);
            loader.IgnoreManifest = true;
            loader.AsSync().Start();
            if (!loader.IsOk)
            {
                AssetLoaderPool.Put(loader);
                Finish(loader.Error, null);
                return;
            }

            var manifestAssetBundle = loader.AssetBundle;
            var manifest = manifestAssetBundle.LoadAsset<AssetBundleManifest>("AssetBundleManifest");
            manifestAssetBundle.Unload(false);
            AssetLoaderPool.Put(loader);
            Finish(null, manifest);
        }
    }
}