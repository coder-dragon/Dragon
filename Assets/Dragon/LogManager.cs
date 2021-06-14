using Dragon.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Dragon
{
    /// <summary>
    /// 日志管理器
    /// </summary>
    public static class LogManager
    {
        public static LogLevel LogLevel { get { return LogLevel.All; } }

        /// <summary>
        /// 获取或创建指定模块名称的日志记录器。
        /// </summary>
        /// <param name="type">模块类型</param>
        /// <returns>日志记录器</returns>
        public static Log GetLogger(Type type)
        {
            if (type == null)
                throw new ArgumentException(nameof(type));
            return GetLogger(type.FullName);
        }

        /// <summary>
        /// 获取或创建指定模块名称的日志记录器。
        /// </summary>
        /// <param name="moduleName">模块名称</param>
        /// <returns>日志记录器</returns>
        public static Log GetLogger(string moduleName)
        {
            if (moduleName == null)
                moduleName = string.Empty;

            Log ret;
            if (!_loggers.TryGetValue(moduleName, out ret))
            {
                ret = new Log(moduleName);
                _loggers.Add(moduleName, ret);
            }

            return ret;
        }

        private static readonly Dictionary<string, Log> _loggers= new Dictionary<string, Log>(128);
    }
}
