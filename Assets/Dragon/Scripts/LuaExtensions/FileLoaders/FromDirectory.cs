using Dragon.EditorOnly;
using System;
using System.IO;
using UnityEngine.SocialPlatforms;

namespace Dragon.LuaExtensions.FileLoaders
{
    /// <summary>
    /// 基于目录结构的Lua文件加载器
    /// </summary>
    public class FromDirectory
    {
        public FromDirectory(string rootPath)
        {
            _rootPath = rootPath;
        }

        public byte[] ReadFile(ref string filePath)
        {
            filePath = filePath.Replace(".", "/");
            byte[] bytes = readFileInternal($"{_rootPath}/{filePath}.lua", ref filePath);
            if (bytes == null)
                bytes = readFileInternal($"{_rootPath}/{filePath}/.init.lua", ref filePath);
            return bytes;
        }

        private byte[] readFileInternal(string fullPath, ref string filePath)
        {
            if (!File.Exists(fullPath))
                return null;
#if UNITY_EDITOR_WIN
            // GetWindowsPhysicalPath不支持中文判断，会返回空值
            string physicaPath = ProjectPath.GetWindowsPhysicalPath(fullPath);
            if (fullPath != physicaPath && !string.IsNullOrEmpty(physicaPath))
                throw new ArgumentException("路径大小写错误：\n" + fullPath + "\n" + physicaPath);
#endif
            filePath = fullPath;
            return File.ReadAllBytes(filePath);
        }

        private readonly string _rootPath;
    }
}