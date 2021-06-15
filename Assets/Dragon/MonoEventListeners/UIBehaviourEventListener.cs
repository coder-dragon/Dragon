namespace Dragon.MonoEventListeners
{
    using Dragon;
    using UnityEngine;
    using UnityEngine.Events;
    using UnityEngine.EventSystems;

    /// <summary>
    /// 用于<see cref="UIBehaviour"/>相关事件的监听器。
    /// </summary>
    public class UIBehaviourEventListener : UIBehaviour
    {
        /// <summary>
        /// 当UI的尺寸变更时触发此事件。
        /// </summary>
        public UnityEvent DimensionsChanged = new UnityEvent();

        /// <summary>
        /// 从指定的游戏对象上获取<see cref="UIBehaviourEventListener"/>，若不存在则会创建一个。
        /// </summary>
        /// <param name="gameObject">游戏对象</param>
        public static UIBehaviourEventListener Get(GameObject gameObject)
        {
            var listener = gameObject.GetOrAddComponent<UIBehaviourEventListener>();
            return listener;
        }

        protected override void OnRectTransformDimensionsChange()
        {
            if (DimensionsChanged != null)
                DimensionsChanged.Invoke();
        }
    }
}