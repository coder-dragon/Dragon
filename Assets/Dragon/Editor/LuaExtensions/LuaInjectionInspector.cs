using Dragon.LuaExtensions;
using System;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEditorInternal;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

namespace Dragon.Editor.LuaExtensions
{
    /// <summary>
    /// 扩展<see cref="LuaInjection"/>在编辑器面板中的显示操作逻辑
    /// </summary>
    [CustomEditor(typeof(LuaInjection))]
    public class LuaInjectionInspector : UnityEditor.Editor
    {
        public override void OnInspectorGUI()
        {
            _luaInjection = target as LuaInjection;
            if (_luaInjection == null )
            {
                base.OnInspectorGUI();
                return;
            }

            GUILayout.Space(10);

            GUILayout.BeginHorizontal();
            drawDropZone();
            drawAutoCollectionButton();
            drawCloseRaycastTargetButton();
            drawLockButton();
            GUILayout.EndHorizontal();
            _reorderableList?.DoLayoutList();
        }

        private void OnEnable()
        {
            _luaInjection = target as LuaInjection;
            if (_luaInjection == null)
                return;
            _reorderableList = new ReorderableList(_luaInjection.Fields, typeof(LuaFieldPair), true, true, true, true);
            _reorderableList.onAddCallback = onAddItem;
            _reorderableList.onRemoveCallback = onRemoveItem;
            _reorderableList.drawHeaderCallback = onDrawHeader;
            _reorderableList.drawElementCallback = onDrawElement;
        }

        private void OnDisable()
        {
            if (_reorderableList == null)
                return;
            _reorderableList.onAddCallback = null;
            _reorderableList.onRemoveCallback = null;
            _reorderableList.drawHeaderCallback = null;
            _reorderableList.drawElementCallback = null;
            _reorderableList = null;
        }

        private void onAddItem(ReorderableList list)
        {
            Undo.RecordObject(target, "LuaInjection,AddItem");
            _luaInjection.Fields.Add(new LuaFieldPair
            {
                K = string.Empty,
                T = LuaFieldType.GameObject
            });
            EditorUtility.SetDirty(target);
        }

        private void onRemoveItem(ReorderableList list)
        {
            Undo.RecordObject(target, "LuaInjection,RemoveItem");
            _luaInjection.Fields.RemoveAt(list.index);
            EditorUtility.SetDirty(target);
        }

        private void onDrawElement(Rect rect, int index, bool isActive, bool isFocused)
        {
            var fieldPair = _luaInjection.Fields[index];
            EditorGUI.BeginChangeCheck();

            const int padding = 4;

            var h = rect.height - padding;
            var x = rect.x;
            var y = rect.y + padding;

            var typeRect = new Rect(x, y, 60, h);
            x += typeRect.width + padding;

            var maxKeyWidth = Mathf.Max(10.0f, (rect.width - typeRect.width - padding - padding) * 0.5f);
            var keyRect = new Rect(x, y, 120, h);
            if (keyRect.width > maxKeyWidth)
                keyRect.width = maxKeyWidth;
            x += keyRect.width + padding;
            var valueRect = new Rect(x, y, rect.width - typeRect.width - keyRect.width - padding, h);

            var newType = (LuaFieldType)EditorGUI.EnumPopup(typeRect, fieldPair.T);
            if (!LuaInjectionUtility.TryConvertToLuaField(fieldPair, newType))
            {
                fieldPair.T = newType;
                fieldPair.V = null;
                fieldPair.V1 = null;
                fieldPair.V2 = 0;
            }

            var originColor = GUI.backgroundColor;
            GUI.backgroundColor = hasDuplicatedField(fieldPair.K) ? Color.red : Color.green;

            switch (fieldPair.T)
            {
                case LuaFieldType.GameObject:
                    {
                        var k = EditorGUI.TextField(keyRect, fieldPair.K);
                        valueRect.width -= 18;
                        var v = EditorGUI.ObjectField(valueRect, fieldPair.V, typeof(GameObject), true);
                        if (string.IsNullOrEmpty(k) && v != null)
                        {
                            k = v.name;
                            var inference = LuaInjectionUtility.ComponentTypeInference(v as GameObject);
                            if (inference != null)
                            {
                                fieldPair.T = LuaFieldType.Component;
                                v = inference;
                            }
                        }
                        fieldPair.K = k;
                        fieldPair.V = v;
                        drawComponentsDropdown(valueRect.x + valueRect.width, valueRect.y, ref fieldPair);
                        break;
                    }
                case LuaFieldType.String:
                    fieldPair.K = EditorGUI.TextField(keyRect, fieldPair.K);
                    fieldPair.V1 = EditorGUI.TextField(valueRect, fieldPair.V1);
                    break;
                case LuaFieldType.Asset:
                    fieldPair.K = EditorGUI.TextField(keyRect, fieldPair.K);
                    fieldPair.V = EditorGUI.ObjectField(valueRect, fieldPair.V, typeof(UnityEngine.Object), false);
                    break;
                case LuaFieldType.Number:
                    fieldPair.K = EditorGUI.TextField(keyRect, fieldPair.K);
                    fieldPair.V2 = EditorGUI.FloatField(valueRect, fieldPair.V2);
                    break;
                case LuaFieldType.Boolean:
                    fieldPair.K = EditorGUI.TextField(keyRect, fieldPair.K);
                    var toggleResult = EditorGUI.Toggle(valueRect, fieldPair.V2 != 0);
                    fieldPair.V2 = toggleResult ? 1 : 0;
                    break;
                case LuaFieldType.Component:
                    {
                        var k = EditorGUI.TextField(keyRect, fieldPair.K);
                        if (fieldPair.V == null || fieldPair.V is GameObject)
                        {
                            fieldPair.T = LuaFieldType.GameObject;
                            _luaInjection.Fields[index] = fieldPair;
                        }

                        if (fieldPair.V is Component)
                        {
                            valueRect.width -= 18;
                            var v = EditorGUI.ObjectField(valueRect, fieldPair.V, typeof(GameObject), true);
                            if (string.IsNullOrEmpty(k) && v != null)
                                k = v.name;

                            fieldPair.K = k;
                            drawComponentsDropdown(valueRect.x + valueRect.width, valueRect.y, ref fieldPair);
                        }

                        break;
                    }
                default:
                    throw new ArgumentOutOfRangeException();
            }

            GUI.backgroundColor = originColor;

            if (EditorGUI.EndChangeCheck())
            {
                Undo.RecordObject(_luaInjection, "LuaInjection.ModifyField");
                _luaInjection.Fields[index] = fieldPair;
                EditorUtility.SetDirty(target);
            }
        }

        private static void drawComponentsDropdown(float x, float y, ref LuaFieldPair pair)
        {
            if (pair.V == null)
                return;

            GUI.backgroundColor = Color.white;
            var rect = new Rect(x, y, 16, 16);
            var options = new List<string> { "--- Game Object Only ---" };
            GameObject gameObject;
            Component component;
            if (pair.V is Component)
            {
                component = (Component)pair.V;
                gameObject = component.gameObject;
            }
            else
            {
                component = null;
                gameObject = (GameObject)pair.V;
            }

            var components = gameObject.GetComponents<Component>();
            options.AddRange(components.Select(c => c.GetType().Name));
            var currentIndex = Array.IndexOf(components, component) + 1;
            var selectedIndex = EditorGUI.Popup(rect, currentIndex, options.ToArray());
            if (currentIndex != selectedIndex)
                GUI.changed = true;
            if (selectedIndex == 0)
            {
                pair.T = LuaFieldType.GameObject;
                pair.V = gameObject;
            }
            else
            {
                pair.T = LuaFieldType.Component;
                pair.V = components[selectedIndex - 1];
            }
        }

        private void onDrawHeader(Rect rect)
        {
            GUI.Label(rect, "Lua Fields");
            rect.width = 100;
            rect.height =100;
        }

        private bool hasDuplicatedField(string fieldName)
        {
            if (_luaInjection.Fields == null)
                return false;
            if (string.IsNullOrEmpty(fieldName))
                return true;

            var count = 0;
            for (var i = 0; i < _luaInjection.Fields.Count; i++)
            {
                if (_luaInjection.Fields[i].K == fieldName)
                {
                    if (count > 0)
                        return true;
                    count++;
                }
            }
            return false;
        }

        private void drawDropZone()
        {
            float RECT_HEIGHT = 50.0f;
            var content = new GUIContent("添加引擎对象");
            int controlID = GUIUtility.GetControlID(998654321, FocusType.Passive);
            Rect rect = GUILayoutUtility.GetRect(content, GUI.skin.box, GUILayout.ExpandWidth(true), GUILayout.Height(RECT_HEIGHT));

            var eventType = Event.current.type;
            if (_dropZoneStyle == null)
            {
                _dropZoneStyle = new GUIStyle(GUI.skin.box);
                _dropZoneStyle.alignment = TextAnchor.MiddleCenter;
            }
            switch (eventType)
            {
                case EventType.DragUpdated:
                case EventType.DragPerform:
                    if (rect.Contains(Event.current.mousePosition))
                    {
                        DragAndDrop.activeControlID = controlID;
                        DragAndDrop.visualMode = DragAndDropVisualMode.Copy;

                        if (eventType == EventType.DragPerform && DragAndDrop.objectReferences.Length > 0)
                        {
                            Undo.RecordObject(_luaInjection, "向LuaBehaviour添加了一堆东西");
                            foreach (var obj2 in DragAndDrop.objectReferences)
                            {
                                var obj = obj2;
                                string name = obj.name;
                                LuaFieldType type = EditorUtility.IsPersistent(obj) ? LuaFieldType.Asset : LuaFieldType.GameObject;
                                //如果拖入的object是一个Texture2D，并且只包含一个sprite，则可能想要拖入的是一个Sprite。
                                //自动转换成Sprite
                                if (type == LuaFieldType.Asset && obj is Texture2D)
                                {
                                    LuaInjectionUtility.TryConvertToSpriteAsset(ref obj);
                                }

                                //if name is duplicatted, then create a good name.
                                if (_luaInjection.Fields.Any(x => x.K == name))
                                {
                                    name = ObjectNames.GetUniqueName(_luaInjection.Fields.Select(x => x.K).ToArray(), name);
                                }

                                _luaInjection.Fields.Add(new LuaFieldPair()
                                {
                                    K = name,
                                    T = type,
                                    V = obj
                                });
                            }
                        }
                        Event.current.Use();
                    }
                    break;
            }


            if (Event.current.type == EventType.Repaint)
            {
                var oldColor = GUI.color;
                if (DragAndDrop.activeControlID == controlID)
                {
                    content.text = "正在准备添加" + DragAndDrop.objectReferences.Length + "个东西";
                    _dropZoneStyle.normal.textColor = Color.gray;
                }
                else
                {
                    _dropZoneStyle.normal.textColor = Color.white;
                    _dropZoneStyle.fontSize = 24;
                }
                _dropZoneStyle.Draw(rect, content, controlID);
                GUI.color = oldColor;
            }
        }

        private void drawLockButton()
        {
            float RECT_HEIGHT = 50.0f;
            var content = new GUIContent("锁定\n面板");
            Rect rect = GUILayoutUtility.GetRect(content, GUI.skin.box, GUILayout.ExpandWidth(false), GUILayout.Height(RECT_HEIGHT), GUILayout.Width(RECT_HEIGHT));
            var isLocked = ActiveEditorTracker.sharedTracker.isLocked;
            if(isLocked)
            {
                if (GUI.Button(rect, "解锁\n面板"))
                {
                    ActiveEditorTracker.sharedTracker.isLocked = !ActiveEditorTracker.sharedTracker.isLocked;
                    ActiveEditorTracker.sharedTracker.ForceRebuild();
                }
            }
            else
            {
                if (GUI.Button(rect, "锁定\n面板"))
                {
                    ActiveEditorTracker.sharedTracker.isLocked = !ActiveEditorTracker.sharedTracker.isLocked;
                    ActiveEditorTracker.sharedTracker.ForceRebuild();
                }
            }
        }

        private delegate void Operate(GameObject go);

        private void recurveGameObject(GameObject obj, Operate operate)
        {
            operate(obj);
            for (int i = 0; i < obj.transform.childCount; i++)
                recurveGameObject(obj.transform.GetChild(i).gameObject, operate);
        }


        private void collectChildReference(GameObject obj)
        {
            var inference = LuaInjectionUtility.ComponentTypeInference(obj);
            var Fields = _luaInjection.Fields;
            if (inference != null)
            {
                foreach (var luaFieldPair in Fields)
                {
                    if(luaFieldPair.K == obj.name)
                        return;
                }
                Undo.RecordObject(target, "LuaInjection,AddItem");
                Fields.Add(new LuaFieldPair
                {
                    K = obj.name,
                    T = LuaFieldType.Component,
                    V = inference
                });
            }
        }

        private void drawAutoCollectionButton()
        {
            float RECT_HEIGHT = 50.0f;
            var content = new GUIContent("收集组件");
            Rect rect = GUILayoutUtility.GetRect(content, GUI.skin.box, GUILayout.ExpandWidth(false), GUILayout.Height(RECT_HEIGHT), GUILayout.Width(RECT_HEIGHT));
            if (GUI.Button(rect, "收集\n组件"))
            {
                recurveGameObject(_luaInjection.gameObject, collectChildReference);
                EditorUtility.SetDirty(target);
            }
        }

        private void optimizeComponent(GameObject obj)
        {
            //优化事件检测
            var components = obj.GetComponents<IEventSystemHandler>();
            var graphics = obj.GetComponents<Graphic>();
            foreach (var graphic in graphics)
                graphic.raycastTarget = components.Length > 0;

            //优化模板
            var mask = obj.GetComponentInParent<Mask>();
            var mask2d = obj.GetComponentInParent<RectMask2D>();
            var maskable = mask != null || mask2d != null;
            var maskableGraphics = obj.GetComponents<MaskableGraphic>();
            foreach (var maskableGraphic in maskableGraphics)
                maskableGraphic.maskable = maskable;
        }

        private void drawCloseRaycastTargetButton()
        {
            float RECT_HEIGHT = 50.0f;
            var content = new GUIContent("优化界面","优化项目包括：\n关闭无用RaycasTarget\n关闭无用模板测试");
            Rect rect = GUILayoutUtility.GetRect(content, GUI.skin.box, GUILayout.ExpandWidth(false), GUILayout.Height(RECT_HEIGHT), GUILayout.Width(RECT_HEIGHT));
            if (GUI.Button(rect, "优化\n界面"))
            {
                recurveGameObject(_luaInjection.gameObject, optimizeComponent);
                EditorUtility.SetDirty(target);
            }
        }


        private LuaInjection _luaInjection;
        private ReorderableList _reorderableList;
        private GUIStyle _dropZoneStyle;
    }
}
