using Dragon.Pooling;

namespace Dragon
{
    /// <summary>
    /// 资源加载器接口
    /// </summary>
    public interface IAssetLoader : IPoolable
    {
        /// <summary>
        /// 获取错误日志
        /// </summary>
        string Error { get; }

        /// <summary>
        /// 获取一个值，表示加载任务是否已经结束
        /// </summary>
        bool IsDone { get; }

        /// <summary>
        /// 获取加载进度
        /// </summary>
        float Progress { get; }

        /// <summary>
        /// 获取加载的结果
        /// </summary>
        object Result { get; }

        /// <summary>
        /// 获取需要加载的资源的定位标识符
        /// </summary>
        string Uri { get; }

        /// <summary>
        /// 启动加载器
        /// </summary>
        void Start();
    }

}