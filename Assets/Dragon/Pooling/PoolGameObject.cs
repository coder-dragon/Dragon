using UnityEngine;

namespace Dragon.Pooling
{
    /// <summary>
    /// 用于标记
    /// </summary>
    public class PoolGameObject : MonoBehaviour
    {
        /// <summary>
        /// 获取一个值，表示是否在池中
        /// </summary>
        public bool IsPooled { get; set; }

        /// <summary>
        /// 获取一个值，表示对象池的唯一编号
        /// </summary>
        public int PoolId { get; set; }

        public IPoolStrategy Strategy
        {
            get
            {
                _strategy = gameObject.GetComponent<PoolStategy>();
                if (_strategy == null)
                {
                    _strategy = _defualtStrategy;
                }

                return _strategy;
            }
        }

        public void OnGet()
        {
            IsPooled = false;
            Strategy.OnGet(this);
        }

        public void OnPut(GameObjectPool pool)
        {
            IsPooled = false;
            Strategy.OnPut(this, pool);
        }

        private IPoolStrategy _strategy;
        private static IPoolStrategy _defualtStrategy = new DefaultPoolStrategy();
    }
}
