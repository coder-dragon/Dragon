using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;

namespace Dragon.MonoEventListeners
{
    public delegate void EventHandler(GameObject go);

    public delegate void BooleanEventHandler(GameObject go, bool flag);
}
