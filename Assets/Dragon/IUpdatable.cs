namespace Dragon
{
    /// <summary>
    /// 更新接口，实现此接口以供每帧调用
    /// </summary>
    public interface IUpdatable
    {
        /// <summary>
        /// 更新逻辑
        /// </summary>
        void Update();
    }
}
