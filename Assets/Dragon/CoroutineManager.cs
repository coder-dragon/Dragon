using System;
using System.Collections;
using UnityEngine;
using Dragon.Logging;

namespace Dragon
{

    /// <summary>
    /// 协同程序管理器，用于提供非<see cref="MonoBehaviour">的类使用协同
    /// </summary>
    public static class CoroutineManager
    {
        /// <summary>
        /// 用于执行协同程序的<see cref="MonoBehaviour">
        /// </summary>
        [Singleton]
        public class CoroutineRunner : MonoBehaviour
        {

        }

        /// <summary>
        /// 初始化管理器
        /// </summary>
        [RuntimeInitializeOnLoadMethod]
        public static void Initialize()
        {
            if (_initialize)
                return;
            _runner = Singleton.Get<CoroutineRunner>();
            _initialize = true;
        }

        /// <summary>
        /// 启动一个新的协同程序
        /// </summary>
        /// <param name="coroutine">启动协同程序所需的迭代器</param>
        /// <returns>创建的协同程序</returns>
        public static Coroutine StartCoroutine(IEnumerator coroutine)
        {
            return _runner.StartCoroutine(coroutine);
        }

        /// <summary>
        /// 按秒数延迟执行一个方法。
        /// </summary>
        /// <param name="seconds">需要延迟的秒数</param>
        /// <param name="ignoreTimeScale">是否要忽略Time.timeScale</param>
        /// <param name="action">需要执行的方法</param>
        public static Coroutine TimeDelayExecute(float seconds, bool ignoreTimeScale, Action action)
        {
            return _runner.StartCoroutine(timeDelayExecute(seconds, ignoreTimeScale, action));
        }

        /// <summary>
        /// 在下一帧执行指定的方法。
        /// </summary>
        /// <param name="action">需要指定的方法</param>
        public static Coroutine ExecuteOnNextFrame(Action action)
        {
            return _runner.StartCoroutine(frameDelayExecute(1, action));
        }

        /// <summary>
        /// 按帧数延迟执行一个方法。
        /// </summary>
        /// <param name="frame">需要延迟的帧数</param>
        /// <param name="action">需要执行的方法</param>
        public static Coroutine FrameDelayExecute(int frame, Action action)
        {
            return _runner.StartCoroutine(frameDelayExecute(frame, action));
        }

        public static void StopCoroutine(Coroutine coroutine)
        {
            if (DragonEngine.IsShuttingDown)
                return;
            if(coroutine == null)
            {
                _log.Warn("Trying to stop a null coroutine");
            }
            _runner.StopCoroutine(coroutine);
        }

        public static void StopAll()
        {
            _runner.StopAllCoroutines();
        }



        private static IEnumerator frameDelayExecute(int frame, Action action)
        {
            for (var i = 0; i < frame; i++)
                yield return null;
            action();
        }

        private static IEnumerator timeDelayExecute(float seconds, bool ignoreTimeScale, Action action)
        {
            if (ignoreTimeScale)
                yield return new WaitForSecondsRealtime(seconds);
            else
                yield return new WaitForSeconds(seconds);
            action();
        }

        private static bool _initialize;
        private static CoroutineRunner _runner;
        private static Log _log = LogManager.GetLogger(typeof(CoroutineManager));
    }
}
