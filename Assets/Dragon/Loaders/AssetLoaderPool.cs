using System;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;
using UnityEngine.PlayerLoop;

namespace Dragon.Loaders
{
    /// <summary>
    /// 可重用的资源加载器的池实现。
    /// </summary>
    [Singleton]
    public class AssetLoaderPool : MonoBehaviour
    {
        private class AssetLoaderCache : Dictionary<string, AssetLoaderBase>
        {
            public AssetLoaderCache(Type type)
            {
                _constructor = type.GetConstructor(Type.EmptyTypes);
                if (_constructor == null)
                    throw new ArgumentException();
            }

            public AssetLoaderBase CreateLoader(string uri)
            {
                var ret = (AssetLoaderBase)_constructor.Invoke(null);
                this[uri] = ret;
                ret.CreateFromPool(uri);
                return ret;
            }

            private readonly ConstructorInfo _constructor;
        }

        /// <summary>
        /// 获取或设置自动清理的时间间隔。
        /// </summary>
        public static float CleanupInterval { get; set; } = 10f;

        /// <summary>
        /// 创建指定类型的资源加载器。
        /// </summary>
        /// <param name="type">加载器类型</param>
        /// <param name="uri">资源定位标识符</param>
        public static AssetLoaderBase Create(Type type, string uri)
        {
            var ret = (AssetLoaderBase)Activator.CreateInstance(type);
            ret.CreateFromPool(uri);
            return ret;
        }

        /// <summary>
        /// 创建指定类型的资源加载器。
        /// </summary>
        /// <param name="uri">资源定位标识符</param>
        public static T Create<T>(string uri) where T : AssetLoaderBase, new()
        {
            var ret = Activator.CreateInstance<T>();
            ret.CreateFromPool(uri);
            return ret;
        }

        /// <summary>
        /// 从池中获取一个指定类型的加载器，若不存在则创建一个新的
        /// </summary>
        /// <param name="type">资源加载器类型</param>
        /// <param name="uri">资源定位标识符</param>
        /// <returns></returns>
        public static AssetLoaderBase Get(Type type, string uri)
        {
            if (type == null)
                throw new ArgumentException(nameof(type));
            if (uri == null)
                throw new ArgumentException(uri);
            var cache = getCache(type);
            if (cache.TryGetValue(uri, out var ret))
            {
                _disposedLoaders.Remove(ret);
                if (_pendingLoaders.Remove(ret))
                    ret.Resurrect();
                ret.GetFromPool();
                return ret;
            }
            ret = cache.CreateLoader(uri);
            return ret;
        }

        /// <summary>
        /// 从池中获取一个指定类型的加载器，若不存在则创建一个新的
        /// </summary>
        /// <param name="uri">资源定位标识符</param>
        public static T Get<T>(string uri) where T : AssetLoaderBase
        {
            return (T)Get(typeof(T), uri);
        }

        /// <summary>
        /// 回收指定的资源加载器
        /// </summary>
        /// <param name="loader"></param>
        public static void Put(AssetLoaderBase loader)
        {
            if (loader == null || loader.IsDisposed)
                return;
            if (DragonEngine.IsShuttingDown)
                return;
            loader.ReturnToPool();
            _pendingLoaders.Add(loader);
            if (loader.IsReadyForDispose)
                _disposedLoaders.Add(loader);
        }

        /// <summary>
        /// 强制清理所有资源加载器，慎用
        /// </summary>
        public static void UnLoadAll()
        {
            foreach (var cache in _cacheLoaders.Values)
            {
                foreach (var pair in cache)
                {
                    pair.Value.Dispose(true);
                }
            }
            _cacheLoaders.Clear();
            _pendingLoaders.Clear();
            _disposedLoaders.Clear();
        }

        /// <summary>
        /// 清理所有可卸载资源加载器
        /// </summary>
        private static void cleanup()
        {
            foreach (var loader in _disposedLoaders)
            {
                if (_cacheLoaders.TryGetValue(loader.GetType(), out var cache))
                    cache.Remove(loader.Uri);
                _pendingLoaders.Remove(loader);
                loader.Dispose();
            }
            _disposedLoaders.Clear();
        }

        private static AssetLoaderCache getCache(Type type)
        {
            if (_cacheLoaders.TryGetValue(type, out var ret))
                return ret;
            ret = new AssetLoaderCache(type);
            _cacheLoaders[type] = ret;
            return ret;
        }

        private static void Update()
        {
            if (_lastCleanupTime < 0 || Time.time - _lastCleanupTime >= CleanupInterval)
                cleanup();
            _lastCleanupTime = Time.time;
        }

        /// <summary>
        /// 初始化管理器。
        /// </summary>
        [RuntimeInitializeOnLoadMethod]
        public static void Initialize()
        {
            if (_initialized)
                return;
            _instance = Singleton.Get<AssetLoaderPool>();
            _initialized = true;
        }

        private static AssetLoaderPool _instance;
        private static bool _initialized;
        private static float _lastCleanupTime = -1;
        private static readonly Dictionary<Type, AssetLoaderCache> _cacheLoaders = new Dictionary<Type, AssetLoaderCache>();
        private static readonly HashSet<AssetLoaderBase> _pendingLoaders = new HashSet<AssetLoaderBase>();
        private static readonly List<AssetLoaderBase> _disposedLoaders = new List<AssetLoaderBase>();
    }
}

