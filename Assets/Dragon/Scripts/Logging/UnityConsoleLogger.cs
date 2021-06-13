namespace Dragon.Logging
{
    public class UnityConsoleLogger : ILogger
    {

        public void Verbose(object content)
        {
            UnityEngine.Debug.Log(content);
        }

        public void VerboseFormat(string format, params object[] args)
        {
            var content = string.Format(format, args);
            UnityEngine.Debug.Log(content);
        }
        public void Debug(object content)
        {
            UnityEngine.Debug.Log(content);
        }

        public void DebugFormat(string format, params object[] args)
        {
            var content = string.Format(format, args);
            UnityEngine.Debug.Log(content);
        }

        public void Info(object content)
        {
            UnityEngine.Debug.Log(content);
        }

        public void InfoFormat(string format, params object[] args)
        {
            var content = string.Format(format, args);
            UnityEngine.Debug.Log(content);
        }

        public void Warn(object content)
        {
            UnityEngine.Debug.LogWarning(content);
        }

        public void WarnFormat(string format, params object[] args)
        {
            var content = string.Format(format, args);
            UnityEngine.Debug.LogWarning(content);
        }

        public void Error(object content)
        {
            UnityEngine.Debug.LogError(content);
        }

        public void ErrorFormat(string format, params object[] args)
        {
            var content = string.Format(format, args);
            UnityEngine.Debug.LogError(content);
        }

        public void Trace(object content)
        {
            UnityEngine.Debug.Log(content);
        }

        public void TraceFormat(string format, params object[] args)
        {
            var content = string.Format(format, args);
            UnityEngine.Debug.Log(content);
        }

        public void Fatal(object content)
        {
            UnityEngine.Debug.LogError(content);
        }

        public void FatalFormat(string format, params object[] args)
        {
            var content = string.Format(format, args);
            UnityEngine.Debug.LogError(content);
        }
    }
}
