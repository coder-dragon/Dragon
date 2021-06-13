namespace Dragon.Pooling
{
    /// <summary>
    /// 可重用对象接口
    /// </summary>
    public interface IPoolable
    {
        /// <summary>
        /// 当从池中取出该对象时调用此方法。
        /// </summary>
        void OnGet();

        /// <summary>
        /// 当将该对象存到池中调用此方法。
        /// </summary>
        void OnPut();
    }
}
