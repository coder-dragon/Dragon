using UnityEngine;

namespace Dragon.Pooling
{
    public abstract class PoolStategy : MonoBehaviour, IPoolStrategy
    {
        public abstract void OnGet(PoolGameObject obj);
        public abstract void OnPut(PoolGameObject obj, GameObjectPool pool);
    }
}