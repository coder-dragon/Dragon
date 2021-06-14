namespace Dragon.Pooling
{
    /// <summary>
    /// 当对象池需要扩张时，指定调整大小的方式
    /// </summary>
    public enum PoolInflationType
    {
        /// <summary>
        /// 池的大小+1
        /// </summary>
        Increment,
        
        /// <summary>
        /// 池的大小x2
        /// </summary>
        Double
    }
}