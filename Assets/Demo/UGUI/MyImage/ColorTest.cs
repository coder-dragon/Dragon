using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ColorTest : MonoBehaviour
{
    private Button _button;
    
    private Image _image;

    void changeColor()
    {
        _image.color = Color.red;
    }
    // Start is called before the first frame update
    void Start()
    {
        _button = GetComponent<Button>();
        _image = GetComponent<Image>();
        _button.onClick.AddListener(changeColor);
    }
    
    // Update is called once per frame
    void Update()
    {
        
    }
}
