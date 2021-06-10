using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Dragon.LuaExtensions
{
    public static class UnityEngineObjectExtention
    {
        /// <summary>
        /// 扩展游戏对象判空的方法
        /// </summary>
        /// <param name="o"></param>
        /// <returns></returns>
        public static bool IsNull(this UnityEngine.Object o)
        {
            return o == null;
        }
    }
}
