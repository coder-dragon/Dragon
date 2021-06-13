namespace Dragon.Logging
{
#if !UNITY_EDITOR
    using System.Diagnostics;
#endif
    using UnityObject = UnityEngine.Object;
    using UnityDebug = UnityEngine.Debug;

    /// <summary>
    /// 提供编译时剔除和运行时按模块过滤的日志记录器。
    /// </summary>
    public sealed class Log
    {
        /// <summary>
        /// 获取或设置当前日志等级。
        /// </summary>
        public LogLevel LogLevel
        {
            get { return mLogLevel ?? LogManager.LogLevel; }
            set { mLogLevel = value; }
        }

        /// <summary>
        /// 获取日志记录器所对应的模块名。
        /// </summary>
        public string ModuleName { get; private set; }

        /// <summary>
        /// 构造一个<see cref="Log"/>，并指定其对应的模块名。
        /// </summary>
        /// <param name="moduleName">模块名称</param>
        public Log(string moduleName)
        {
            ModuleName = moduleName;
        }

        private LogLevel? mLogLevel;

        #region

        /// <summary>
        /// 记录跟踪日志。
        /// </summary>
        /// <param name="message">信息</param>
        public void Trace(object message)
        {
            if (LogLevel > LogLevel.Trace)
                return;
            UnityDebug.Log(message);
        }

        /// <summary>
        /// 记录跟踪日志。
        /// </summary>
        /// <param name="message"></param>
        /// <param name="context"></param>
        public void Trace(object message, UnityObject context)
        {
            if (LogLevel > LogLevel.Trace)
                return;
            UnityDebug.LogWarning(message, context);
        }

        /// <summary>
        /// 记录格式化跟踪日志。
        /// </summary>
        /// <param name="format">信息格式</param>
        /// <param name="args">格式参数</param>
        public void TraceFormat(string format, params object[] args)
        {
            if (LogLevel > LogLevel.Trace)
                return;
            var text = string.Format(format, args);
            UnityDebug.Log(text);
        }

        /// <summary>
        /// 记录格式化跟踪日志。
        /// </summary>
        /// <param name="format">信息格式</param>
        /// <param name="context">上下文</param>
        /// <param name="args">格式参数</param>
        public void TraceFormat(string format, UnityObject context, params object[] args)
        {
            if (LogLevel > LogLevel.Trace)
                return;
            var text = string.Format(format, args);
            UnityDebug.LogError(text, context);
        }

        #endregion

        #region Info

        /// <summary>
        /// 记录信息日志。
        /// </summary>
        /// <param name="message">信息</param>
        public void Info(object message)
        {
            if (LogLevel > LogLevel.Info)
                return;
            UnityDebug.Log(message);
        }

        /// <summary>
        /// 记录信息日志。
        /// </summary>
        /// <param name="message"></param>
        /// <param name="context"></param>
        public void Info(object message, UnityObject context)
        {
            if (LogLevel > LogLevel.Info)
                return;
            UnityDebug.LogWarning(message, context);
        }

        /// <summary>
        /// 记录格式化信息日志。
        /// </summary>
        /// <param name="format">信息格式</param>
        /// <param name="args">格式参数</param>
        public void InfoFormat(string format, params object[] args)
        {
            if (LogLevel > LogLevel.Info)
                return;
            var text = string.Format(format, args);
            UnityDebug.Log(text);
        }

        /// <summary>
        /// 记录格式化信息日志。
        /// </summary>
        /// <param name="format">信息格式</param>
        /// <param name="context">上下文</param>
        /// <param name="args">格式参数</param>
        public void InfoFormat(string format, UnityObject context, params object[] args)
        {
            if (LogLevel > LogLevel.Info)
                return;
            var text = string.Format(format, args);
            UnityDebug.LogError(text, context);
        }

        #endregion

        #region Error

        /// <summary>
        /// 记录错误信息。
        /// </summary>
        /// <param name="message">信息</param>
        public void Error(object message)
        {
            if (LogLevel > LogLevel.Error)
                return;
            UnityDebug.LogError(message);
        }

        /// <summary>
        /// 记录错误信息。
        /// </summary>
        /// <param name="message">信息</param>
        /// <param name="context">上下文</param>
        public void Error(object message, UnityObject context)
        {
            if (LogLevel > LogLevel.Error)
                return;
            UnityDebug.LogError(message, context);
        }

        /// <summary>
        /// 记录格式化错误信息。
        /// </summary>
        /// <param name="format">信息格式</param>
        /// <param name="args">格式参数</param>
        public void ErrorFormat(string format, params object[] args)
        {
            if (LogLevel > LogLevel.Error)
                return;
            var text = string.Format(format, args);
            UnityDebug.LogError(text);
        }

        /// <summary>
        /// 记录格式化错误信息。
        /// </summary>
        /// <param name="format">信息格式</param>
        /// <param name="context">上下文</param>
        /// <param name="args">格式参数</param>
        public void ErrorFormat(string format, UnityObject context, params object[] args)
        {
            if (LogLevel > LogLevel.Error)
                return;
            var text = string.Format(format, args);
            UnityDebug.LogError(text, context);
        }

        #endregion

        #region Error

        /// <summary>
        /// 记录错误信息。
        /// </summary>
        /// <param name="message">信息</param>
        public void Fatal(object message)
        {
            if (LogLevel > LogLevel.Error)
                return;
            UnityDebug.LogError(message);
        }

        /// <summary>
        /// 记录错误信息。
        /// </summary>
        /// <param name="message">信息</param>
        /// <param name="context">上下文</param>
        public void Fatal(object message, UnityObject context)
        {
            if (LogLevel > LogLevel.Error)
                return;
            UnityDebug.LogError(message, context);
        }

        /// <summary>
        /// 记录格式化错误信息。
        /// </summary>
        /// <param name="format">信息格式</param>
        /// <param name="args">格式参数</param>
        public void FatalFormat(string format, params object[] args)
        {
            if (LogLevel > LogLevel.Error)
                return;
            var text = string.Format(format, args);
            UnityDebug.LogError(text);
        }

        /// <summary>
        /// 记录格式化错误信息。
        /// </summary>
        /// <param name="format">信息格式</param>
        /// <param name="context">上下文</param>
        /// <param name="args">格式参数</param>
        public void FatalFormat(string format, UnityObject context, params object[] args)
        {
            if (LogLevel > LogLevel.Error)
                return;
            var text = string.Format(format, args);
            UnityDebug.LogError(text, context);
        }

        #endregion

        #region Warning

        /// <summary>
        /// 记录警告信息。
        /// </summary>
        /// <param name="message">信息</param>
        public void Warn(object message)
        {
            if (LogLevel > LogLevel.Warn)
                return;
            UnityDebug.LogWarning(message);
        }

        /// <summary>
        /// 记录警告信息。
        /// </summary>
        /// <param name="message">信息</param>
        /// <param name="context">上下文</param>
        public void Warn(object message, UnityObject context)
        {
            if (LogLevel > LogLevel.Warn)
                return;
            UnityDebug.LogWarning(message, context);
        }

        /// <summary>
        /// 记录格式化警告信息。
        /// </summary>
        /// <param name="format">信息格式</param>
        /// <param name="args">格式参数</param>
        public void WarnFormat(string format, params object[] args)
        {
            if (LogLevel > LogLevel.Warn)
                return;
            var text = string.Format(format, args);
            UnityDebug.LogWarning(text);
        }

        /// <summary>
        /// 记录格式化警告信息。
        /// </summary>
        /// <param name="format">信息格式</param>
        /// <param name="context">上下文</param>
        /// <param name="args">格式参数</param>
        public void WarnFormat(string format, UnityObject context, params object[] args)
        {
            if (LogLevel > LogLevel.Warn)
                return;
            var text = string.Format(format, args);
            UnityDebug.LogWarning(text, context);
        }

        #endregion

        #region Debug

        /// <summary>
        /// 记录调试信息。
        /// </summary>
        /// <param name="message">信息</param>
#if !UNITY_EDITOR
        [Conditional("DEBUG_OUTPUT")]
#endif
        public void Debug(object message)
        {
            if (LogLevel > LogLevel.Debug)
                return;
            UnityDebug.Log(message);
        }

        /// <summary>
        /// 记录调试信息。
        /// </summary>
        /// <param name="message">信息</param>
        /// <param name="context">上下文</param>
#if !UNITY_EDITOR
        [Conditional("DEBUG_OUTPUT")]
#endif
        public void Debug(object message, UnityObject context)
        {
            if (LogLevel > LogLevel.Debug)
                return;
            UnityDebug.Log(message, context);
        }

        /// <summary>
        /// 记录格式化调试信息。
        /// </summary>
        /// <param name="format">信息格式</param>
        /// <param name="args">格式参数</param>
#if !UNITY_EDITOR
        [Conditional("DEBUG_OUTPUT")]
#endif
        public void DebugFormat(string format, params object[] args)
        {
            if (LogLevel > LogLevel.Debug)
                return;
            var text = string.Format(format, args);
            UnityDebug.Log(text);
        }

        /// <summary>
        /// 记录格式化调试信息。
        /// </summary>
        /// <param name="format">信息格式</param>
        /// <param name="context">上下文</param>
        /// <param name="args">格式参数</param>
#if !UNITY_EDITOR
        [Conditional("DEBUG_OUTPUT")]
#endif
        public void DebugFormat(string format, UnityObject context, params object[] args)
        {
            if (LogLevel > LogLevel.Debug)
                return;
            var text = string.Format(format, args);
            UnityDebug.Log(text, context);
        }

        #endregion end

        #region Verbose

        /// <summary>
        /// 记录调试信息。
        /// </summary>
        /// <param name="message">信息</param>
#if !UNITY_EDITOR
        [Conditional("DEBUG_OUTPUT")]
#endif
        public void Verbose(object message)
        {
            if (LogLevel > LogLevel.Verbose)
                return;
            UnityDebug.Log(message);
        }

        /// <summary>
        /// 记录详细调试信息。
        /// </summary>
        /// <param name="message">信息</param>
        /// <param name="context">上下文</param>
#if !UNITY_EDITOR
        [Conditional("DEBUG_OUTPUT")]
#endif
        public void Verbose(object message, UnityObject context)
        {
            if (LogLevel > LogLevel.Verbose)
                return;
            UnityDebug.Log(message, context);
        }

        /// <summary>
        /// 记录格式化详细调试信息。
        /// </summary>
        /// <param name="format">信息格式</param>
        /// <param name="args">格式参数</param>
#if !UNITY_EDITOR
        [Conditional("DEBUG_OUTPUT")]
#endif
        public void VerboseFormat(string format, params object[] args)
        {
            if (LogLevel > LogLevel.Verbose)
                return;
            var text = string.Format(format, args);
            UnityDebug.Log(text);
        }

        /// <summary>
        /// 记录格式化详细调试信息。
        /// </summary>
        /// <param name="format">信息格式</param>
        /// <param name="context">上下文</param>
        /// <param name="args">格式参数</param>
#if !UNITY_EDITOR
        [Conditional("DEBUG_OUTPUT")]
#endif
        public void VerboseFormat(string format, UnityObject context, params object[] args)
        {
            if (LogLevel > LogLevel.Verbose)
                return;
            var text = string.Format(format, args);
            UnityDebug.Log(text, context);
        }

        #endregion end
    }
}