using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class UILayerOrder : MonoBehaviour
{
    public Canvas Canvas { get; private set; }

        /// <summary>
        /// 获取一级子节点上所有的<see cref="UILayerOrder"/>组件。
        /// </summary>
        public List<UILayerOrder> Children
        {
            get
            {
                if (mChildren == null)
                    mChildren = new List<UILayerOrder>();
                return mChildren;
            }
        }

        public int FinalOrder => (Parent == null ? 0 : Parent.FinalOrder) + order;

        public int Order
        {
            get => order;
            set
            {
                if (order == value)
                    return;
                order = value;
                OnOrderChanged();
            }
        }

        public UILayerOrder Parent { get; private set; }

        public Renderer Renderer { get; private set; }

        public SortingGroup SortingGroup { get; private set; }

        protected bool IsRoot { get; set; }

        [ContextMenu("ForceUpdate")]
        public void ForceUpdate()
        {
            mIsInitialized = false;
            initialize();
            if (Parent != null)
                Parent.Children.Remove(this);
            Parent = null;
            detectParent();
        }

        protected virtual void OnOrderChanged()
        {
            update();
            foreach (var child in Children)
                child.OnParentOrderChanged();
        }

        protected virtual void OnParentOrderChanged()
        {
            update();
            foreach (var child in Children)
                child.OnParentOrderChanged();
        }

        protected virtual void Start()
        {
            initialize();
        }

        private void detectParent()
        {
            if (IsRoot)
                return;
            var oldParent = Parent;
            if (Parent == null || !transform.IsChildOf(Parent.transform))
            {
                Parent = getUILayerOrderInFirstParent();
            }
            if (oldParent != Parent)
                onParentChanged(oldParent, Parent);
        }

        private UILayerOrder getUILayerOrderInFirstParent()
        {
            var trans = transform;
            while (true)
            {
                var parent = trans.parent;
                if (parent == null)
                    return null;
                var ret = parent.GetComponent<UILayerOrder>();
                if (ret != null)
                    return ret;
                trans = parent;
            }
        }

        private void initialize()
        {
            if (mIsInitialized)
                return;

            SortingGroup = GetComponent<SortingGroup>();
            if (SortingGroup != null)
            {
                mUpdateAction = updateSortingGroup;
                mIsInitialized = true;
                return;
            }

            Renderer = GetComponent<Renderer>();
            if (Renderer != null)
            {
                mUpdateAction = updateRenderer;
                mIsInitialized = true;
                return;
            }

            Canvas = gameObject.GetComponent<Canvas>();
            if (Canvas != null)
            {
                mUpdateAction = updateCanvas;
                mIsInitialized = true;
            }

            detectParent();
        }

        private void OnEnable()
        {
            initialize();
        }

        private void onParentChanged(UILayerOrder oldParent, UILayerOrder newParent)
        {
            if (oldParent != null)
                oldParent.Children.Remove(this);
            if (newParent != null)
                newParent.Children.Add(this);
            update();
            if (mChildren == null)
                return;
            foreach (var child in mChildren)
                child.update();
        }

        private void Reset()
        {
            mIsInitialized = false;
        }

        private void update()
        {
            initialize();
            mUpdateAction?.Invoke();
        }

        private void Update()
        {
#if UNITY_EDITOR
            initialize();
#endif
            detectParent();
        }

        private void updateCanvas()
        {
            Canvas.overrideSorting = true;
            Canvas.sortingOrder = FinalOrder;
        }

        private void updateRenderer()
        {
            Renderer.sortingOrder = FinalOrder;
        }

        private void updateSortingGroup()
        {
            SortingGroup.sortingOrder = FinalOrder;
        }

        private List<UILayerOrder> mChildren;
        private bool mIsInitialized;
        private Action mUpdateAction;

        [SerializeField]
        private int order;
}
