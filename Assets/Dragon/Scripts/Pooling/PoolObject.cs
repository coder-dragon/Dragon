using System.Runtime.InteropServices.WindowsRuntime;

namespace Dragon.Pooling
{
    public class PoolObject : IPoolable
    {
        /// <summary>
        /// 获取一个值，表示是否在池中
        /// </summary>
        public bool IsPooled { get { return isPooled; } }

        /// <summary>
        /// 获取一个值，表示对象池的唯一编号
        /// </summary>
        public int PoolId { get; set; }

        public void OnGet()
        {
            isPooled = false;
        }

        public void OnPut()
        {
            isPooled = false;
        }

        private bool isPooled;
    }
}
