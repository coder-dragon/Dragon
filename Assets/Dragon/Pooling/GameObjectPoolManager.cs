using System;
using System.Collections.Generic;
using Dragon.Logging;
using UnityEngine;
using UnityEngine.Assertions;
using Object = UnityEngine.Object;

namespace Dragon.Pooling
{
    /// <summary>
    /// <see cref="GameObject"/>的对象池管理器
    /// </summary>
    [Singleton]
    public class GameObjectPoolManager : MonoBehaviour
    {
        /// <summary>
        /// 获取对象池管理器的唯一实例
        /// </summary>
        public static GameObjectPoolManager Instance
        {
            get
            {
                if (_instance == null)
                    _instance = Singleton.Get<GameObjectPoolManager>();
                return _instance;
            }
        }

        /// <summary>
        /// 创建一个对象池
        /// </summary>
        /// <param name="poolId">对象池编号</param>
        /// <param name="prefab">预设</param>
        /// <param name="initialSize">对象池初始大小</param>
        /// <returns></returns>
        public GameObjectPool Create(int poolId, Object prefab, int initialSize)
        {
            Assert.IsFalse(_pools.ContainsKey(poolId),$"this pool is already create,why are you create it again");
            Assert.IsNotNull(prefab,"prefab can not be null");
            var pool = new GameObjectPool(poolId, prefab, transform, initialSize, PoolInflationType.Increment);
            _pools[poolId] = pool;
            return pool;
        }

        /// <summary>
        /// 获取指定编号的对象池
        /// </summary>
        /// <param name="poolId">对象池编号</param>
        /// <returns>对象池</returns>
        public GameObjectPool GetPool(int poolId)
        {
            if (!_pools.TryGetValue(poolId, out var pool))
                return null;
            return pool;
        }

        /// <summary>
        /// 从指定编号的对象池中获取对象
        /// </summary>
        /// <param name="poolId">对象池编号</param>
        /// <returns>对象池中的对象</returns>
        public GameObject Get(int poolId)
        {
            if (!_pools.TryGetValue(poolId, out var pool))
                return null;
            var go = pool.Get();
            return go;
        }
        
        /// <summary>
        /// 将对象放入指定的池中
        /// </summary>
        /// <param name="obj">需要放入的对象</param>
        public void Put(GameObject obj)
        {
            if (obj == null)
                throw new ArgumentException($"attempts to put a null value");
            var pgo = obj.GetComponent<PoolGameObject>();
            if (pgo == null)
                throw new ArgumentException($"object is not a pooled instance. name:{obj.name}");
            if (_pools.TryGetValue(pgo.PoolId, out var pool))
            {
                pool.Put(pgo.gameObject);
            }
            else
            {
                _log.Warn($"do not find the pool.the pool must be created and not dispose.");
            }
        }

        /// <summary>
        /// 清理指定的对象池
        /// </summary>
        /// <param name="poolId">对象池编号</param>
        public void Clear(int poolId)
        {
            if (!_pools.TryGetValue(poolId, out var pool))
                return;
            pool.Clear();
        }

        /// <summary>
        /// 清理所有对象池
        /// </summary>
        public void ClearAll()
        {
            foreach (var pair in _pools)
            {
                pair.Value.Clear();
            }
        }

        /// <summary>
        /// 删除指定的对象池
        /// </summary>
        /// <param name="poolId">对象池编号</param>
        public void DeletePool(int poolId)
        {
            if (!_pools.TryGetValue(poolId, out var pool))
            {
                _log.Warn($"do not find the pool.the pool must be created and not dispose.");
                return;
            }
            _pools.Remove(poolId);
            pool.Dispose();
        } 
        
        private static GameObjectPoolManager _instance;
        private readonly Dictionary<int, GameObjectPool> _pools = new Dictionary<int, GameObjectPool>();
        private static Log _log = LogManager.GetLogger(typeof(GameObjectPoolManager));
    }
}