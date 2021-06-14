using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;

namespace Dragon
{
    /// <summary>
    /// 为<see cref="GameObject">提供常用的功能和扩展
    /// </summary>
    public static class GameObjectExtenstion
    {
        /// <summary>
        /// 获取或者增加一个指定的组件
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="go"></param>
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
        /// <param name="go"></param>
        /// <param name="type"></param>
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
        /// <typeparam name="T"></typeparam>
        /// <param name="go"></param>
        /// <returns>组件是否存在</returns>
        public static bool RemoveComponent<T>(this GameObject go) where T : Component
        {
            var component = go.GetComponent<T>();
            if (component == null)
                return false;
            UnityEngine.Object.Destroy(component);
            return true;
        }
    }
}
