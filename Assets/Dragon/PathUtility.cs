#if UNITY_EDITOR
using Dragon.EditorOnly;
#endif
using UnityEngine;

namespace Dragon
{
    /// <summary>
    /// 所有路径相关的逻辑。
    /// </summary>
    public static class PathUtility
    {
        /// <summary>
        /// 获取下载目录的全路径。
        /// 如：C:/RevengeClient/PersistentData
        /// </summary>
        public static string PersistentDataPath
        {
            get
            {
                if (mPersistentDataPath == null)
                {
#if UNITY_EDITOR
                    mPersistentDataPath = ProjectPath.Get("PersistentData");
#else
                    mPersistentDataPath = Application.persistentDataPath;
#endif
                }
                return mPersistentDataPath;
            }
        }

        /// <summary>
        /// 获取StreamingAssets的路径。
        /// 如：
        /// Windows Standalone：file:///E:/Projects/Blaze/Assets/StreamingAssets
        /// </summary>
        public static string StreamingAssetsPath
        {
            get
            {
                if (mStreamingAssetsPath == null)
                {
#if UNITY_EDITOR_OSX || UNITY_STANDALONE_OSX
                    mStreamingAssetsPath = "file://" + Application.streamingAssetsPath;
#elif UNITY_EDITOR || UNITY_STANDALONE_WIN
                    mStreamingAssetsPath = "file:///" + Application.streamingAssetsPath;
#elif UNITY_ANDROID
                    mStreamingAssetsPath = "jar:file://" + Application.dataPath + "!/assets";
#elif UNITY_IOS
                    mStreamingAssetsPath = "file:///" + Application.streamingAssetsPath;
#else
                    mStreamingAssetsPath = Application.streamingAssetsPath;
#endif
                }
                return mStreamingAssetsPath;
            }
        }

        /// <summary>
        /// 获取临时缓存目录的全路径。如：C:/RevengeClient/TemporaryCache
        /// </summary>
        public static string TemporaryCachePath
        {
            get
            {
                if (mTemporaryCachePath == null)
                {
#if UNITY_EDITOR
                    mTemporaryCachePath = ProjectPath.Get("TemporaryCache");
#else
                    mTemporaryCachePath = Application.temporaryCachePath;
#endif
                }
                return mTemporaryCachePath;
            }
        }

        /// <summary>
        /// 统一路径分隔符为斜杠“/”。
        /// </summary>
        /// <param name="path">需要修改的路径</param>
        public static string FormatSeperator(string path)
        {
            return path.Replace('\\', '/');
        }

        /// <summary>
        /// 获取相对于本地存储目录的路径。如：1.png -> C:/DMJ/PersistentData/1.png
        /// </summary>
        /// <param name="relativePath">相对路径</param>
        /// <returns>全路径</returns>
        public static string GetPersistentDataPath(string relativePath)
        {
            return $"{PersistentDataPath}/{relativePath}";
        }

        /// <summary>
        /// 获取StreamingAssets的路径。
        /// 如：
        /// Windows Standalone：file:///E:/Projects/Blaze/Assets/StreamingAssets
        /// </summary>
        public static string GetStreamingAssetsPath(string relativePath)
        {
            return $"{StreamingAssetsPath}/{relativePath}";
        }

        /// <summary>
        /// 获取临时缓存目录的全路径。如：C:/RevengeClient/TemporaryCache
        /// </summary>
        public static string GetTemporaryCachePath(string relativePath)
        {
            return $"{TemporaryCachePath}/{relativePath}";
        }

        private static string mPersistentDataPath;
        private static string mStreamingAssetsPath;
        private static string mTemporaryCachePath;
    }
}