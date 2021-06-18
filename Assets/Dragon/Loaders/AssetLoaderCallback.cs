using System;

namespace Dragon.Loaders
{
    /// <summary>
    /// 加载的回调委托。
    /// </summary>
    /// <typeparam name="T">加载器类型</typeparam>
    /// <param name="loader">加载器</param>
    public delegate void AssetLoaderCallback<in T>(T loader) where T : AssetLoaderBase;

    /// <summary>
    /// 加载的回调委托。
    /// </summary>
    /// <param name="loader">加载器</param>
    public delegate void AssetLoaderCallback(AssetLoaderBase loader);
}
