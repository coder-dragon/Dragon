﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Dragon.Utilities
{
    public class DontDestroyOnLoad : MonoBehaviour
    {
        private void Awake()
        {
            DontDestroyOnLoad(gameObject);
        }
    }
}
