using UnityEngine;

namespace Dragon.Loaders
{
    /// <summary>
    /// 从流中加载<see cref="AssetBundle"/>资源包
    /// </summary>
    public class SreamAssetBundleLoader : AssetLoaderBase
    {

        public AssetBundle AssetBundle => (AssetBundle) Result;
        public override float Progress => base.Progress;

        protected override void OnStart()
        {
            base.OnStart();
        }

        protected override void OnDispose()
        {
            base.OnDispose();
        }
    }
}