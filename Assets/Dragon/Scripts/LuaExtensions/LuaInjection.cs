using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;

namespace Dragon.LuaExtensions
{
    public class LuaInjection : MonoBehaviour
    {
        public List<LuaFieldPair> Fields = new List<LuaFieldPair>();

        /// <summary>
        /// 向指定的lua表注入字段
        /// </summary>
        /// <param name="table"></param>
        public void Inject(LuaTable table)
        {
            if (table == null)
                throw new ArgumentException(nameof(table));

            foreach (var pair in Fields)
            {
                switch (pair.T)
                {
                    case LuaFieldType.GameObject:
                        table.Set(pair.K, pair.V);
                        break;
                    case LuaFieldType.String:
                        table.Set(pair.K, pair.V1);
                        break;
                    case LuaFieldType.Number:
                        table.Set(pair.K, pair.V2);
                        break;
                    case LuaFieldType.Boolean:
                        table.Set(pair.K, pair.V2 != 0);
                        break;
                    case LuaFieldType.Component:
                    case LuaFieldType.Asset:
                        table.Set(pair.K, pair.V);
                        break;
                }
            }
        }
    }
}
