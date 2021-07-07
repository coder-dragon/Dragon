using UnityEngine;

namespace Dragon.UI
{
    [ExecuteInEditMode]
    [DisallowMultipleComponent]
    public class UILayer : UILayerOrder
    {
        public UILayer()
        {
            IsRoot = true;
        }

        protected override void OnOrderChanged()
        {
            base.OnOrderChanged();
            Canvas.planeDistance = 1000 - Order;
        }

        protected override void Start()
        {
            base.Start();
            Canvas.planeDistance = 1000 - Order;
        }
    }
}