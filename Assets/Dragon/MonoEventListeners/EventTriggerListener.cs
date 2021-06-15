namespace Dragon.MonoEventListeners
{
    using System.Collections.Generic;
    using Dragon;
    using UnityEngine;
    using UnityEngine.EventSystems;

    /// <summary>
    /// 事件监听器。
    /// </summary>
    public class EventTriggerListener : EventTrigger
    {
        /// <summary>
        /// 从指定的游戏对象上获取<see cref="EventTriggerListener"/>，若不存在则会创建一个。
        /// </summary>
        /// <param name="gameObject">游戏对象</param>
        public static EventTriggerListener Get(GameObject gameObject)
        {
            var listener = gameObject.GetOrAddComponent<EventTriggerListener>();
            return listener;
        }

        private TriggerEvent getOrCreateTriggerEvent(EventTriggerType eventId)
        {
            TriggerEvent ret;
            if (mTriggerEvents.TryGetValue(eventId, out ret))
                return ret;

            ret = new TriggerEvent();
            triggers.Add(new Entry
            {
                callback = ret,
                eventID = eventId,
            });
            mTriggerEvents.Add(eventId, ret);
            return ret;
        }

        private readonly Dictionary<EventTriggerType, TriggerEvent> mTriggerEvents = new Dictionary<EventTriggerType, TriggerEvent>(4);

        #region 事件

        #region 滚动事件

        public TriggerEvent Scroll
        {
            get { return getOrCreateTriggerEvent(EventTriggerType.Scroll); }
        }

        #endregion

        #region 选择事件

        public TriggerEvent Select
        {
            get { return getOrCreateTriggerEvent(EventTriggerType.Select); }
        }

        public TriggerEvent UpdateSelected
        {
            get { return getOrCreateTriggerEvent(EventTriggerType.UpdateSelected); }
        }

        public TriggerEvent Cancel
        {
            get { return getOrCreateTriggerEvent(EventTriggerType.Cancel); }
        }

        public TriggerEvent Deselect
        {
            get { return getOrCreateTriggerEvent(EventTriggerType.Deselect); }
        }


        public TriggerEvent Submit
        {
            get { return getOrCreateTriggerEvent(EventTriggerType.Submit); }
        }

        #endregion

        #region 点击事件

        public TriggerEvent PointerClick
        {
            get { return getOrCreateTriggerEvent(EventTriggerType.PointerClick); }
        }

        public TriggerEvent PointerDown
        {
            get { return getOrCreateTriggerEvent(EventTriggerType.PointerDown); }
        }

        public TriggerEvent PointerEnter
        {
            get { return getOrCreateTriggerEvent(EventTriggerType.PointerEnter); }
        }

        public TriggerEvent PointerExit
        {
            get { return getOrCreateTriggerEvent(EventTriggerType.PointerExit); }
        }

        public TriggerEvent PointerUp
        {
            get { return getOrCreateTriggerEvent(EventTriggerType.PointerUp); }
        }

        #endregion

        #region 拖放事件

        public TriggerEvent Move
        {
            get { return getOrCreateTriggerEvent(EventTriggerType.Move); }
        }

        public TriggerEvent InitializePotentialDrag
        {
            get { return getOrCreateTriggerEvent(EventTriggerType.InitializePotentialDrag); }
        }

        public TriggerEvent Drag
        {
            get { return getOrCreateTriggerEvent(EventTriggerType.Drag); }
        }

        public TriggerEvent EndDrag
        {
            get { return getOrCreateTriggerEvent(EventTriggerType.EndDrag); }
        }

        public TriggerEvent BeginDrag
        {
            get { return getOrCreateTriggerEvent(EventTriggerType.BeginDrag); }
        }

        public TriggerEvent Drop
        {
            get { return getOrCreateTriggerEvent(EventTriggerType.Drop); }
        }

        #endregion

        #endregion
    }
}