namespace Dragon.Logging
{
    /// <summary>
    /// 日志记录器接口
    /// </summary>
    public interface ILogger
    {

        void Verbose(object content);

        void VerboseFormat(string format, params object[] args);

        void Debug(object content);

        void DebugFormat(string format, params object[] args);

        void Info(object content);

        void InfoFormat(string format, params object[] args);

        void Warn(object content);

        void WarnFormat(string format, params object[] args);

        void Error(object content);

        void ErrorFormat(string format, params object[] args);

        void Trace(object content);

        void TraceFormat(string format, params object[] args);

        void Fatal(object content);

        void FatalFormat(string format, params object[] args);
    }
}
