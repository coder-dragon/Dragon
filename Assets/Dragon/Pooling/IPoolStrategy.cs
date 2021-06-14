namespace Dragon.Pooling
{
    /// <summary>
    /// 对象池策略
    /// </summary>
    public interface IPoolStrategy
    {
        void OnGet(PoolGameObject obj);

        void OnPut(PoolGameObject obj, GameObjectPool pool);
    }
}
