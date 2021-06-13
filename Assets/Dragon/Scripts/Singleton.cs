using Dragon.Utilities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;

namespace Dragon
{
    /// <summary>
    /// 单例管理器。
    /// </summary>
    public class Singleton : MonoBehaviour
    {
        /// <summary>
        /// 获取单例对象管理器的根节点
        /// </summary>
        public static GameObject Root
        {
            get
            {
                if(_root == null)
                {
                    _root = new GameObject(_rootName) { name = _rootName};
                    DontDestroyOnLoad(_root);
                }
                return _root;
            }
        }

        public static T Get<T>() where T : Component
        {
            var type = typeof(T);
            if(_componentCache.TryGetValue(type, out var component))
            {
                if (component == null)
                    _componentCache.Remove(type);
                else
                    return (T) component;
            }

            var attribute = getSingletonAttribute(type);
            string error = null;
            if (attribute == null)
                throw new ArgumentException($"Can't find SingletonAttribute in {type}.");

            if (attribute.PrefabPath != null)
            {
                //create from prefab
                var obj = (GameObject)Resources.Load(attribute.PrefabPath);
                if (obj == null)
                {
                    error = $"Can't find prefab in '{attribute.PrefabPath}'";
                }
                else
                {
                    obj = Instantiate(obj);
                    obj.name = type.Name;
                    component = obj.GetComponent<T>();
                    if (component == null)
                        error = $"Can't find {type} in prefab '{attribute.PrefabPath}'";
                }
            }
            else if (attribute.CreateByManual)
            {
                //Find from scene
                component = FindObjectOfType<T>();
                error = $"Can't find {type} in gameobject hierarchy.";
            }
            else
            {
                //create by default
                var obj = new GameObject(type.Name);
                component = obj.AddComponent<T>();
            }

            if (component == null)
                throw new InvalidOperationException(error);

            if (attribute.DontDestroyOnLoad)
                component.transform.parent = getTransformByPath(Root.transform, attribute.Hierarchy);

            _componentCache.Add(type, component);
            return (T) component;
        }

        private static SingletonAttribute getSingletonAttribute(Type type)
        {
            var ret = type.GetCustomAttributes(typeof(SingletonAttribute), false).FirstOrDefault() as SingletonAttribute;
            return ret;
        }

        /// <summary>
        /// 获取一个值，表示指定的单例组件是否存在
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <returns>是否存在</returns>
        public static bool Exists<T>()
        {
            var type = typeof(T);
            return _componentCache.ContainsKey(type);
        }

        #region Create transform by path

        private static Transform getOrCreateChild(Transform root, string childName)
        {
            var child = root.Find(childName);
            if (child != null)
                return child;
            var childObj = new GameObject(childName);
            child = childObj.transform;
            child.parent = root;
            return child;
        }

        private static Transform getTransformByPath(Transform root, string path)
        {
            while (true)
            {
                if (string.IsNullOrEmpty(path))
                    return root;
                var index = path.IndexOf('/');
                if (index < 0)
                {
                    var child = getOrCreateChild(root, path);
                    return child;
                }
                else
                {
                    var childPath = path.Substring(0, index);
                    var child = getOrCreateChild(root, childPath);
                    root = child;
                    path = path.Substring(index + 1);
                }
            }
        }

        #endregion

        private const string _rootName = "Singleton";
        private static GameObject _root;
        private static readonly Dictionary<Type, Component> _componentCache = new Dictionary<Type, Component>();

    }
}
