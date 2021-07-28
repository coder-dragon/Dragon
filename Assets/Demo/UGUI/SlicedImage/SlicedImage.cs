using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

[ExecuteInEditMode]
public class SlicedImage : MonoBehaviour
{
    
    public Color Color;
    public Texture Texture;
    public Camera Camera;
    
    public float left = 0.2f;
    public float right = 0.2f;
    public float bottom = 0.2f;
    public float up = 0.2f;

    public Rect Rect;
    
    private VertexHelper _vertexHelper = new VertexHelper();

    private Mesh _mesh;

    private MeshFilter _meshFilter;

    private MeshRenderer _meshRenderer;

    private MeshCollider _meshCollider;

    private MeshCollider MeshCollider
    {
        get
        {
            if (_meshCollider == null)
                _meshCollider = GetComponent<MeshCollider>();
            return _meshCollider;
        }
    }

    private MeshRenderer MeshRenderer
    {
        get
        {
            if (_meshRenderer == null)
                _meshRenderer = GetComponent<MeshRenderer>();
            return _meshRenderer;
        }
    }

    private MeshFilter MeshFilter
    {
        get
        {
            if (_meshFilter == null)
                _meshFilter = GetComponent<MeshFilter>();
            return _meshFilter;
        }
    }
    
    static readonly Vector2[] vt = new Vector2[4];
    static readonly Vector2[] uv = new Vector2[4];
    
    private void InitMesh()
    {

        // 获取图片的高度与宽度构造一个Rect
        Rect rect = new Rect(0, 0, Texture.width, Texture.height);

        vt[0] = new Vector2(left * rect.width, bottom * rect.height);

        _mesh = new Mesh();
        _vertexHelper.Clear();
        _vertexHelper.AddVert(new Vector2(0,0), Color, new Vector2(0, 0));
        _vertexHelper.AddVert(new Vector2(0,1), Color, new Vector2(0, 1));
        _vertexHelper.AddVert(new Vector2(1,1), Color, new Vector2(1, 1));
        _vertexHelper.AddVert(new Vector2(1,0), Color, new Vector2(1, 0));
        _vertexHelper.AddTriangle(0, 1, 2);
        _vertexHelper.AddTriangle(2, 3, 0);
        _vertexHelper.FillMesh(_mesh);
        MeshFilter.mesh = _mesh;
    }

    private void InitRender()
    {
        MeshRenderer.sharedMaterial.color = Color;
        MeshRenderer.sharedMaterial.mainTexture = Texture;
    }

    private void InitCollider()
    {
        MeshCollider.sharedMesh = _mesh;
    }

    private void RayCastTarget()
    {
        var ray = Camera.ScreenPointToRay(Input.mousePosition);
        RaycastHit hit;
        Physics.Raycast(ray, out hit);
        if (hit.collider != null && hit.collider.gameObject != null)
        {
            if (Input.GetMouseButtonDown(0))
            {
                Debug.Log("Image Clicked");
            }
        }
        Debug.DrawLine(ray.origin, ray.origin+ray.direction*100, Color.red);
    }
    // Start is called before the first frame update
    void Start()
    {
        InitMesh();
        InitCollider();
        InitRender();
    }

    // Update is called once per frame
    void Update()
    {
        RayCastTarget();
    }
}
