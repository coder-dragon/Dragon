using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Dragon.Pooling;
using UnityEngine;
using UnityEngine.Assertions;

namespace Dragon
{
    /// <summary>
    /// 为<see cref="GameObject">提供常用的功能和扩展
    /// </summary>
    public static class GameObjectExtenstion
    {
        #region GameObject组件扩展
        /// <summary>
        /// 获取或者增加一个指定的组件
        /// </summary>
        /// <typeparam name="T">组件类型</typeparam>
        /// <param name="go">对象自身</param>
        /// <returns>组件</returns>
        public static T GetOrAddComponent<T>(this GameObject go) where T : Component
        {
            var component = go.GetComponent<T>();
            if(component == null)
                component = go.AddComponent<T>();
            return component;
        }

        /// <summary>
        /// 获取或者增加一个指定的组件
        /// </summary>
        /// <param name="go">对象自身</param>
        /// <param name="type">组件类型</param>
        /// <returns>组件</returns>
        public static Component GetOrAddComponent(this GameObject go, Type type)
        {
            var component = go.GetComponent(type);
            if (component == null)
                component = go.AddComponent(type);
            return component;
        }

        /// <summary>
        /// 移除指定类型的组件
        /// </summary>
        /// <typeparam name="T">组件类型</typeparam>
        /// <param name="go">对象自身</param>
        /// <returns>组件是否存在</returns>
        public static bool RemoveComponent<T>(this GameObject go) where T : Component
        {
            var component = go.GetComponent<T>();
            if (component == null)
                return false;
            UnityEngine.Object.Destroy(component);
            return true;
        }
        #endregion

        #region GameObject对象池方法扩展
        
        /// <summary>
        /// 从池中获取实例化的对象自身的克隆
        /// </summary>
        /// <param name="go">预设</param>
        /// <returns>可用的对象</returns>
        public static GameObject GetFromPool(this GameObject go)
        {
            var poolId = go.GetInstanceID();
            var pool = GameObjectPoolManager.Instance.GetPool(poolId);
            if(pool == null)
                pool = GameObjectPoolManager.Instance.Create(poolId, go, 1);
            var result = pool.Get();
            return result;
        }

        /// <summary>
        /// 回收对象自身到对象池
        /// </summary>
        /// <param name="go">对象自身</param>
        public static void ReturnToPool(this GameObject go)
        {
            if (DragonEngine.IsShuttingDown)
                return;
            GameObjectPoolManager.Instance.Put(go);
        }
        
        /// <summary>
        /// 为对象自身创建对象池
        /// </summary>
        /// <param name="go">对象自身</param>
        /// <param name="initialSize">对象池初始大小</param>
        /// <returns>对象池编号</returns>
        public static int CreatePool(this GameObject go, int initialSize)
        {
            var pool = GameObjectPoolManager.Instance.Create(go.GetInstanceID(), go, initialSize);
            return pool.Id;
        }
        
        /// <summary>
        /// 删除对象自身的对象池
        /// </summary>
        /// <param name="go">对象自身</param>
        public static void CreatePool(this GameObject go)
        {
            GameObjectPoolManager.Instance.DeletePool(go.GetInstanceID());
        }
        #endregion
    }
}
