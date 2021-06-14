namespace Dragon.Pooling
{
    /// <summary>
    /// 对象池接口
    /// </summary>
    public interface IObjectPool
    {
        /// <summary>
        /// 从对象池获取一个对象
        /// </summary>
        /// <returns>可用的对象</returns>
        object Get();

        /// <summary>
        /// 将指定对象回收到对象池
        /// </summary>
        /// <param name="obj">对象</param>
        void Put(object obj);
    }

    public interface IObjectPool<T>:IObjectPool
    {
        /// <summary>
        /// 从对象池中获取一个对象。
        /// </summary>
        /// <returns>可用的对象</returns>
        new T Get();

        /// <summary>
        /// 将指定的对象回收到对象池。
        /// </summary>
        /// <param name="obj">对象</param>
        void Put(T obj);
    }
}
