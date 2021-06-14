using System;
using System.Collections.Generic;

namespace Dragon.Pooling
{
    /// <summary>
    /// 对象池模式的实现
    /// </summary>
    /// <typeparam name="T"></typeparam>
    public abstract class ObjectPool<T>:IObjectPool<T> where T:class
    {

        /// <summary>
        /// 获取一个值，表示对象池的容量
        /// </summary>
        public int Capacity { get; set; }

        /// <summary>
        /// 获取当前可用的对象堆栈
        /// </summary>
        protected Stack<T> AvailiableObjects
        {
            get { return _availiableObjects; }
        }

        /// <summary>
        /// 获取当前正在使用的对象列表
        /// </summary>
        protected List<T> InUseObjects
        {
            get { return _inUseObjects; }
        }

        #region IObjectPool Memebers
        
        /// <summary>
        /// 从对象池中获取一个对象
        /// </summary>
        /// <returns>可用的对象</returns>
        object IObjectPool.Get()
        {
            return Get();
        }
        
        /// <summary>
        /// 将指定对象回收到对象池
        /// </summary>
        /// <param name="obj">对象</param>
        public void Put(object obj)
        {
            Put((T) obj);
        }

        #endregion
        
        #region IObjectPool<T> Memebers
        
        /// <summary>
        /// 从对象池中获取一个对象
        /// </summary>
        /// <returns>可用的对象</returns>
        public abstract T Get();
        
        /// <summary>
        /// 将指定对象回收到对象池
        /// </summary>
        /// <param name="obj">对象</param>
        public abstract void Put(T obj);

        #endregion

        /// <summary>
        /// 当需要创建一个新的对象时调用此方法
        /// </summary>
        /// <returns></returns>
        protected abstract T Create();

        /// <summary>
        /// 当需要从对象池获取对象时调用此方法
        /// </summary>
        /// <param name="obj"></param>
        protected virtual void OnGet(T obj)
        {
        }
        
        /// <summary>
        /// 当需要回收指定对象时调用此方法
        /// </summary>
        /// <param name="obj"></param>
        protected virtual void OnPut(T obj)
        {
        }
        
        protected ObjectPool()
        {
            Capacity = int.MaxValue;
            _availiableObjects = new Stack<T>();
            _inUseObjects = new List<T>();
        }

        /// <summary>
        /// 构造一个<see cref="ObjectPool{T}"/>>的实例，并指定最大的容量
        /// </summary>
        /// <param name="capacity">最大容量</param>
        /// <exception cref="ArgumentException">attempts to specify a capacity less than 0</exception>
        protected ObjectPool(int capacity)
        {
            if (capacity <= 0)
                throw new ArgumentException("attempts to specify a capacity less than 0");
            Capacity = capacity;
            _availiableObjects = new Stack<T>();
            _inUseObjects = new List<T>();
        }

        private readonly Stack<T> _availiableObjects = new Stack<T>();
        private readonly List<T> _inUseObjects = new List<T>();
    }
}