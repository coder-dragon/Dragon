namespace Dragon
{
    /// <summary>
    /// 游戏引擎接口
    /// </summary>
    public interface IGameEngine
    {
        /// <summary>
        /// 注册每帧更新调用的对象
        /// </summary>
        /// <param name="updatable">自我更新的对象</param>
        void RegisterUpdate(IUpdatable updatable);

        /// <summary>
        /// 取消注册每帧更新的对象
        /// </summary>
        /// <param name="updatable">自我更新的对象</param>
        void UnRegisterUpdate(IUpdatable updatable);
    }
}
