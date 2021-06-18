namespace Dragon.Loaders
{
    /// <summary>
    /// 扩展资源加载器的调用方式,实现链式调用
    /// </summary>
    public static class AssetLoaderFluentExtension
    {
        /// <summary>
        /// 设置资源加载器以异步方式加载。
        /// </summary>
        public static T AsAsync<T>(this T loader) where T : AssetLoaderBase
        {
            loader.Mode = AssetLoadMode.Async;
            return loader;
        }

        /// <summary>
        /// 设置资源加载器以同步方式加载。
        /// </summary>
        public static T AsSync<T>(this T loader) where T : AssetLoaderBase
        {
            loader.Mode = AssetLoadMode.Sync;
            return loader;
        }
        
        /// <summary>
        /// 启动加载器。
        /// </summary>
        public static T FluentStart<T>(this T loader) where T : AssetLoaderBase
        {
            loader.Start();
            return loader;
        }
        
        /// <summary>
        /// 设置资源加载器的加载模式。
        /// </summary>
        public static T SetMode<T>(this T loader, AssetLoadMode mode) where T : AssetLoaderBase
        {
            loader.Mode = mode;
            return loader;
        }
    }
}