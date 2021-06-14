using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Dragon.LuaExtensions
{
    public enum LuaFieldType
    {
        /// <summary>
        /// 游戏对象
        /// </summary>
        GameObject = 0,

        /// <summary>
        /// 字符串
        /// </summary>
        String = 1,

        /// <summary>
        /// 数字
        /// </summary>
        Number = 2,

        /// <summary>
        /// 布尔值
        /// </summary>
        Boolean = 3,

        /// <summary>
        /// 游戏组件
        /// </summary>
        Component = 4,

        /// <summary>
        /// 资源对象
        /// </summary>
        Asset = 5
    }
}
