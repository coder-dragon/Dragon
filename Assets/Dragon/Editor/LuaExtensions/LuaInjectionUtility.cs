using Dragon.LuaExtensions;
using System;
using System.Linq;
using UnityEditor;
using UnityEngine;
using UnityEngine.UI;

namespace Dragon.Editor.LuaExtensions
{
    public static class LuaInjectionUtility
    {
        public static System.Func<GameObject, Component> ComponentTypeInferenceHook;

        /// <summary>
        /// 游戏需要的组件类型推断
        /// </summary>
        /// <param name="obj"></param>
        /// <returns></returns>
        public static Component ComponentTypeInference(GameObject obj)
        {
            if (obj == null)
                return null;

            try
            {
                Component ret = null;
                if (ComponentTypeInferenceHook != null)
                    ret = ComponentTypeInferenceHook(obj);
                if (ret == null)
                    ret = defaultInference(obj);
                return ret;
            }
            catch (Exception e)
            {
                return null;
            }
        }

        private static Component defaultInference(GameObject obj)
        {
            var name = obj.name;
            if (name == "btn"
                || name.EndsWith("_btn")
                || name.EndsWith("_button")
                || name.EndsWith("Button"))
                return obj.GetComponent<Button>();

            if (name == "img"
                || name.EndsWith("_img")
                || name.EndsWith("_image")
                || name.EndsWith("Image"))
                return obj.GetComponent<Image>() ?? (Component) obj.GetComponent<RawImage>();

            if (name == "txt"
                || name.EndsWith("_txt")
                || name.EndsWith("_text")
                || name.EndsWith("Text"))
                return obj.GetComponent("TMPro.TextMeshProUGUI") ?? obj.GetComponent<Text>();

            if (name.IndexOf("scrollrect", StringComparison.OrdinalIgnoreCase) >= 0
                || name.IndexOf("scroll_rect", StringComparison.OrdinalIgnoreCase) >= 0
                || name.IndexOf("scrollview", StringComparison.OrdinalIgnoreCase) >= 0
                || name.IndexOf("scroll_vect", StringComparison.OrdinalIgnoreCase) >= 0)
                return obj.GetComponent<ScrollRect>();

            if (name == "slider"
                || name.EndsWith("_slider")
                || name.EndsWith("Slider"))
                return obj.GetComponent<Slider>();

            if (name == "toggle"
                || name.EndsWith("_toggle")
                || name.EndsWith("Toggle"))
                return obj.GetComponent<Toggle>();

            if (name == "input"
                || name.EndsWith("_input")
                || name.EndsWith("Input"))
                return obj.GetComponent<InputField>();

            if (name == "animator"
                || name.EndsWith("_animator")
                || name.EndsWith("Animator"))
                return obj.GetComponent<Animator>();

            return null;
        }

        /// <summary>
        /// //如果obj是一个Texture2D asset，则尝试转换成一个Sprite
        /// </summary>
        /// <param name="obj"></param>
        public static void TryConvertToSpriteAsset(ref UnityEngine.Object obj)
        {
            if (obj is Texture2D)
            {
                string path = AssetDatabase.GetAssetPath(obj);
                if (!string.IsNullOrEmpty(path))
                {
                    //当一个texture2d只包含一个sprite的时候，才转换成sprite
                    //否则认为你要拖动的就是一个texture2d
                    var objs = AssetDatabase.LoadAllAssetsAtPath(path);
                    int spriteCount = objs.Count(x => x is Sprite);
                    if (spriteCount == 1)
                    {
                        obj = objs.First(x => x is Sprite);
                    }
                }
            }
        }

        /// <summary>
        /// 尝试将Lua字段信息的类型变更为新类型。
        /// </summary>
        /// <param name="newType">新类型</param>
        /// <returns>是否变更成功</returns>
        public static bool TryConvertToLuaField(LuaFieldPair filePair, LuaFieldType newType)
        {
            if (filePair.T == newType)
                return true;

            if (filePair.T == LuaFieldType.GameObject && newType == LuaFieldType.Component)
            {
                var go = filePair.V as GameObject;
                if (go == null)
                    return false;
                filePair.V = go.GetComponent<Component>();
                filePair.T = newType;
                return true;
            }

            if (filePair.T == LuaFieldType.Component && newType == LuaFieldType.GameObject)
            {
                var c = filePair.V as Component;
                if (c == null || c.gameObject == null)
                    return false;
                filePair.V = c.gameObject;
                filePair.T = newType;
                return true;
            }

            return false;
        }
    }
}