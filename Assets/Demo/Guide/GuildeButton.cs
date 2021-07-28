using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class GuildeButton : MonoBehaviour
{
    private Button _button;
    // Start is called before the first frame update
    void Start()
    {
        _button = gameObject.GetComponent<Button>();
        _button.onClick.AddListener(()=> Debug.Log("按钮点击事件"));
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
