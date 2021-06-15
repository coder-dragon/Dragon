using System;
using System.Collections.Generic;
using Dragon.Logging;
using UnityEditor.VersionControl;
using UnityEngine;
using UnityEngine.Assertions;
using Object = UnityEngine.Object;

namespace Dragon.Pooling
{
    /// <summary>
    /// 用于管理<see cref="PoolGameObject"/>的对象池
    /// </summary>
    public class GameObjectPool:ObjectPool<GameObject>,IDisposable
    {
        /// <summary>
        /// 获取一个值，表示对象池的唯一编号
        /// </summary>
        public int Id { get; }

        /// <summary>
        /// 获取对象池的根节点
        /// </summary>
        public Transform Root { get; }
        
        /// <summary>
        /// 从对象池中获取一个对象
        /// </summary>
        /// <returns>可用的对象</returns>
        public override GameObject Get()
        {
            return getNextAvailableGameObject();
        }

        /// <summary>
        /// 将指定对象回收到对象池
        /// </summary>
        /// <param name="obj">对象</param>
        public override void Put(GameObject obj)
        {
            var pgo = obj.GetComponent<PoolGameObject>();
            Assert.IsTrue(pgo.PoolId == Id, $"try to add the object to the wrong pool PoolGameObject <name = {pgo.gameObject.name} PoolId = {pgo.PoolId}> Pool<Id = {Id}>");
            if(pgo.IsPooled)
                _log.Warn($"{obj.name}  is already in pool. why are you trying to return it again? check usage");
            put(pgo);
        }

        /// <summary>
        /// 当需要创建一个新的对象时调用此方法
        /// </summary>
        /// <returns>新创建的对象</returns>
        protected override GameObject Create()
        {
            var go = (GameObject) Object.Instantiate(_prefab);
            var pgo = go.GetOrAddComponent<PoolGameObject>();
            pgo.PoolId = Id;
            return go;
        }

        /// <summary>
        /// 释放对象池
        /// </summary>
        public void Dispose()
        {
            Clear();
            if (_inUseObjects.Count > 0)
            {
                foreach (var pgo in _inUseObjects)
                {
                    _log.Warn($"pool will be dispose, but PoolGameObject is in use. name -> {pgo.gameObject.name}");
                }
            }

            _prefab = null;
            Object.Destroy(Root.gameObject);
        }

        /// <summary>
        /// 清理对象池
        /// </summary>
        public void Clear()
        {
            if (DragonEngine.IsShuttingDown)
                return;
            while (_availiableObjects.Count > 0)
            {
                var pgo = _availiableObjects.Pop();
                if(pgo != null)
                    Object.Destroy(pgo);
            }
        }

        public GameObjectPool(int id, Object prefab, Transform poolRoot, int initialSize = 1, PoolInflationType inflationType = PoolInflationType.Increment)
        {
            Assert.IsNotNull(prefab,"prefab can not be null");
            Id = id;
            _prefab = prefab;
            _inflationType = inflationType;
            GameObject go = new GameObject(prefab.name);
            go.SetActive(false);
            Root = go.transform;
            Root.SetParent(poolRoot);
            populatePool(initialSize);
        }

        private void populatePool(int initialCount)
        {
            for (int index = 0; index < initialCount; index++)
            {
                var obj = Create();
                var pgo = obj.GetComponent<PoolGameObject>();
                pgo.transform.SetParent(Root, false);
                _availiableObjects.Push(pgo);
            }
        }

        private void put(PoolGameObject pgo)
        {
            pgo.OnPut(this);
            _availiableObjects.Push(pgo);
            _inUseObjects.Remove(pgo);
            pgo.transform.SetParent(Root, false);
        }

        private GameObject getNextAvailableGameObject()
        {
            PoolGameObject po = null;
            if (_availiableObjects.Count > 0)
            {
                po = _availiableObjects.Pop();
            }
            else
            {
                int increaseSize = 0;
                if (_inflationType == PoolInflationType.Increment)
                {
                    increaseSize = 1;
                }
                else if (_inflationType == PoolInflationType.Double)
                {
                    increaseSize = _availiableObjects.Count + _inUseObjects.Count;
                }

                if (increaseSize > 0)
                {
                    populatePool(increaseSize);
                    po = _availiableObjects.Pop();
                }
            }

            GameObject result = null;
            if (po != null)
            {
                _inUseObjects.Add(po);
                po.OnGet();
                result = po.gameObject;
            }

            return result;
        }
        
        private Object _prefab;
        private PoolInflationType _inflationType;
        private readonly Stack<PoolGameObject> _availiableObjects = new Stack<PoolGameObject>();
        private readonly List<PoolGameObject> _inUseObjects = new List<PoolGameObject>();
        private static Log _log = LogManager.GetLogger(typeof(GameObjectPool));
    }
}