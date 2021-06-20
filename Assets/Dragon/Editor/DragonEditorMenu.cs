using System.Text;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;

namespace Dragon.Editor
{
    public class DragonEditorMenu : EditorWindow
    {
        /// <summary>
        /// 快速启动游戏，当游戏停止时自动返回当前正在编辑的场景
        /// </summary>
        [MenuItem("Dragon/快速启动 &F5")]
        private static void QuickStart()
        {
            if (Application.isPlaying || EditorApplication.isCompiling)
                return;
            if (!EditorSceneManager.SaveCurrentModifiedScenesIfUserWantsTo())
                return;
            
        }

        private static void saveCurrentScenePathsToEditorPrefs()
        {
            var buffer = new StringBuilder();
            for (int i = 0; i < EditorSceneManager.loadedSceneCount; i++)
            {
                var scene = EditorSceneManager.GetSceneAt(i);
                buffer.AppendFormat("{0}", scene.path);
                
            }
        }

        private const string _openScenesOnStopPlaying = "OpenScenePathsStopPlaying";
    }
}