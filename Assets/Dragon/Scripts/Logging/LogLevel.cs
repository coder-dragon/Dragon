namespace Dragon.Logging
{
    public enum LogLevel
    {
        /// <summary>
        /// 显示所有日志
        /// </summary>
        All = 0,

        /// <summary>
        /// 冗长
        /// </summary>
        Verbose = 1,

        /// <summary>
        /// 调试
        /// </summary>
        Debug = 2,

        /// <summary>
        /// 信息
        /// </summary>
        Info = 3,

        /// <summary>
        /// 警告 
        /// </summary>
        Warn = 4,

        /// <summary>
        /// 错误
        /// </summary>
        Error = 5,

        /// <summary>
        /// 跟踪程序状态，用于难以定位的问题，release也不会剔除
        /// </summary>
        Trace = 6,

        /// <summary>
        /// 致命错误，程序已经无法正常运行，release也不会剔除
        /// </summary>
        Fatal = 7,

        /// <summary>
        /// 关闭所有日志
        /// </summary>
        Off = 100,

    }
}
