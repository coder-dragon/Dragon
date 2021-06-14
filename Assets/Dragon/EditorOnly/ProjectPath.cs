using System;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;
using UnityEngine;

namespace Dragon.EditorOnly
{
    public static class ProjectPath
    {
        /// <summary>
        /// 获取工程下Assets目录的全路径。
        /// 如：C:/RevengeClient/Assets
        /// </summary>
        public static string Assets
        {
            get
            {
                if (mCachedAssetsPath == null)
                    mCachedAssetsPath = mApplicationDataPath.Replace('\\', '/');
                return mCachedAssetsPath;
            }
        }

        /// <summary>
        /// Lua文件根目录全路径。
        /// 如：C:/RevengeClient/Lua
        /// </summary>
        public static string Lua
        {
            get
            {
                if (mCachedProjectLuaPath == null)
                    mCachedProjectLuaPath = Get("Lua");
                return mCachedProjectLuaPath;
            }
        }

        /// <summary>
        /// 获取工程目录的全路径。
        /// 如：C:/RevengeClient
        /// </summary>
        public static string Root
        {
            get
            {
                if (mCachedProjectPath == null)
                    mCachedProjectPath = PathUtility.FormatSeperator(mApplicationDataPath.Substring(0, mApplicationDataPath.Length - "/Assets".Length));
                return mCachedProjectPath;
            }
        }

        /// <summary>
        /// 获取工程下StreamingAssets目录的全路径，如：C:/RevengeClient/StreamingAssets
        /// </summary>
        public static string StreamingAssets
        {
            get
            {
                if (mCachedProjectStreamingAssetsPath == null) 
                    mCachedProjectStreamingAssetsPath = GetAssets("StreamingAssets");
                return mCachedProjectStreamingAssetsPath;
            }
        }

        /// <summary>
        /// 获取相对于工程目录的路径。如：Assets/1.txt -> C:/RevengeClient/Assets/1.txt
        /// </summary>
        /// <param name="relativePath">相对路径</param>
        /// <returns>全路径</returns>
        public static string Get(string relativePath)
        {
            return PathUtility.FormatSeperator(Path.Combine(Root, relativePath));
        }

        /// <summary>
        /// 获取相对于工程Assets目录的路径， 如：1.txt -> C:/RevengeClient/Assets/1.txt
        /// <param name="isProjectRelativeOnly">是否仅获取相对与工程的路径，如Assets/path.txt</param>
        /// </summary>
        public static string GetAssets(string relativePath, bool isProjectRelativeOnly = false)
        {
            if (isProjectRelativeOnly)
                return "Assets/" + relativePath;
            return string.Concat(Assets, "/", relativePath);
        }

        /// <summary>
        /// 获取相对于工程StreamingAssets目录的路径， 如：1.txt -> C:/RevengeClient/StreamingAssets/1.txt
        /// </summary>
        public static string GetStreamingAssets(string relativePath)
        {
            return PathUtility.FormatSeperator(Path.Combine(StreamingAssets, relativePath));
        }

        /// <summary>
        /// 获取指定路径在Windows下真实大小写的路径。
        /// </summary>
        public static string GetWindowsPhysicalPath(string path)
        {
            var builder = new StringBuilder(255);

            // names with long extension can cause the short name to be actually larger than
            // the long name.
            GetShortPathName(path, builder, builder.Capacity);

            path = builder.ToString();

            var result = GetLongPathName(path, builder, builder.Capacity);
            if (result <= 0)
                return null;

            if (result < builder.Capacity)
            {
                //Success retrieved long file name
                builder[0] = Char.ToUpper(builder[0]);
                return builder.ToString(0, (int) result);
            }

            //Need more capacity in the buffer
            //specified in the result variable
            builder = new StringBuilder((int) result);
            result = GetLongPathName(path, builder, builder.Capacity);
            builder[0] = Char.ToUpper(builder[0]);
            return builder.ToString(0, (int) result);
        }

        /// <summary>
        /// 将全路径裁剪为相对于Assets目录下的路径。
        /// </summary>
        /// <param name="fullPath">全路径</param>
        /// <returns>相对路径</returns>
        public static string StripForAssetPath(string fullPath)
        {
            return PathUtility.FormatSeperator(fullPath.Substring(mApplicationDataPath.Length - "Assets".Length));
        }

        [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Auto)]
        private static extern uint GetLongPathName(string shortPath, StringBuilder sb, int buffer);

        [DllImport("kernel32.dll")]
        private static extern uint GetShortPathName(string longPath, StringBuilder sb, int buffer);

        private static readonly string mApplicationDataPath = Application.dataPath;
        private static string mCachedAssetsPath;
        private static string mCachedProjectLuaPath;
        private static string mCachedProjectPath;
        private static string mCachedProjectStreamingAssetsPath;
    }
}