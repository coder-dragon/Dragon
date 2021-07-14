using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

[ExecuteInEditMode]
public class MyImage : MonoBehaviour
{
    
    public Color Color;
    public Texture Texture;
    public Camera Camera;
    
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
    

    private void InitMesh()
    {
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
        MeshRenderer.material.color = Color;
        MeshRenderer.material.mainTexture = Texture;
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
