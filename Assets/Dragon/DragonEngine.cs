using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;

namespace Dragon
{
    /// <summary>
    /// Dragon核心驱动对象
    /// </summary>
    [Singleton]
    public class DragonEngine : MonoBehaviour, IGameEngine
    {
        /// <summary>
        /// 获取<see cref="DragonEngine">的唯一实例
        /// </summary>
        public static DragonEngine Instance { get; private set; }

        /// <summary>
        /// 获取一个值，表示游戏是否正在退出
        /// </summary>
        public static bool IsShuttingDown { get; private set; }

        /// <summary>
        /// 当屏幕尺寸变更时触发此事件
        /// </summary>
        public event Action ScreenSizeChanged;

        /// <summary>
        /// 当屏幕安全区域变更时触发此事件
        /// </summary>
        public event Action ScreenSafeAreaChanged;

        #region IGameEngine Members
        /// <summary>
        /// 注册每帧更新的对象
        /// </summary>
        /// <param name="updatable">自我更新的对象</param>
        public void RegisterUpdate(IUpdatable updatable)
        {
            updatables.Add(updatable);
        }

        /// <summary>
        /// 取消注册每帧更新的对象
        /// </summary>
        /// <param name="updatable">自我更新的对象</param>
        public void UnRegisterUpdate(IUpdatable updatable)
        {
            updatables.Remove(updatable);
        }
        #endregion

        /// <summary>
        /// 初始化
        /// </summary>
        [RuntimeInitializeOnLoadMethod]
        public static void Initialize()
        {
            if (_initialized)
                return;
            Instance = Singleton.Get<DragonEngine>();
            _initialized = true;
        }

        public void Awake()
        {
            Instance = this;
            _lastScreenWidth = Screen.width;
            _lastScreenHeight = Screen.height;
        }

        protected void Update()
        {
            foreach (var updatable in updatables)
            {
                updatable.Update();
            }
            detectScreen();
        }

        protected void OnApplicationQuit()
        {
            IsShuttingDown = true;    
        }

        private void detectScreen()
        {
            if(Screen.width != _lastScreenWidth || Screen.height != _lastScreenHeight)
            {
                ScreenSizeChanged?.Invoke();
                _lastScreenWidth = Screen.width;
                _lastScreenHeight = Screen.height;
            }
            if(Screen.safeArea != _lastSafeArea)
            {
                ScreenSafeAreaChanged?.Invoke();
                _lastSafeArea = Screen.safeArea;
            }
        }

        private static bool _initialized;
        private static int _lastScreenWidth;
        private static int _lastScreenHeight;
        private Rect _lastSafeArea;
        private readonly List<IUpdatable> updatables = new List<IUpdatable>();
    }
}
