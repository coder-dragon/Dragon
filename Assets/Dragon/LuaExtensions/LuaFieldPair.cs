using System;
using System.Collections.Generic;
using UnityEngine;

namespace Dragon.LuaExtensions
{
    [Serializable]
    public struct LuaFieldPair
    {
        /// <summary>
        /// 在Lua脚本中用于获取引用的键
        /// </summary>
        public string K;

        /// <summary>
        /// 在Lua中获取对象引用所对应的游戏对象或者资源
        /// </summary>
        public UnityEngine.Object V;

        /// <summary>
        /// 在Lua中获取数字类型
        /// </summary>
        public string V1;

        /// <summary>
        /// 在Lua中获取字符串类型
        /// </summary>
        public float V2;

        /// <summary>
        /// 字段类型，根据这个字段来确定使用哪个Value值
        /// </summary>
        public LuaFieldType T;
    }
}
