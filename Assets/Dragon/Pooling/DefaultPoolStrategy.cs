namespace Dragon.Pooling
{
    /// <summary>
    /// 默认的池对象获取回收策略，显示/隐藏游戏对象
    /// </summary>
    public class DefaultPoolStrategy : IPoolStrategy
    {
        public void OnGet(PoolGameObject obj)
        {
            obj.gameObject.SetActive(true);
        }

        public void OnPut(PoolGameObject obj, GameObjectPool pool)
        {
            obj.gameObject.SetActive(false);
        }
    }
}