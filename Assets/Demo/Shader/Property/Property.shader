Shader "Unlit/Property"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        [Normal] _NormalTex ("NormalTex", 2D) = "white" {}
        
        _Rect ("Rect", Rect) = "white" {}
        _Cube ("Cube", Cube) = "white" {}
        _3D ("3D", 3D) = "white" {}
        
        [hideinInspector]
        _Hide ("Hide", Float) = 1.0
        
        [Header(This is a header)]
        [Space]
        _Float ("Float", Float) = 1.0
        _Int ("Int", Int) = 1
        _Vector ("Vector", Vector) = (1, 1, 1, 1)
        _Color ("Color", Color) = (0, 0, 0, 0)
        
        [Toggle] _Toggle ("Toggle", Float) = 0
        
        _Range ("Range", Range(0, 1)) = 1
        [PowerSlider(3.0)] _PowerSlider ("PowerSlider", Range(0, 1)) = 1
        
        [Enum(UnityEngine.Rendering.BlendMode)] _ScrBlend ("Src Blend Mode", Int) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Dst Blend Mode", Int) = 1
        [Enum(UnityEngine.Rendering.CullMode)] _Cull ("Cull Mode", Int) = 2
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest ("ZTest", Int) = 4
        [Enum(Off, 0, On, 1)] _ZWrite ("ZWrite", Int) = 1
        [KeywordEnum(None, Add, Multiply)] _Overlay ("Overlay", Int) = 0
    }
    SubShader 
    {
        Tags { 
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "Preview" = "Plane"
        }
        LOD 100

        Pass
        {
            Name "Test"
            Blend [_ScrBlend] [_DstBlend]
            Cull [_Cull]
            ZTest [_ZTest]
            ZWrite [_ZWrite]
            
            CGPROGRAM

            #pragma shader_feature _OVERLAY_NONE _OVERLAY_ADD _OVERLAY_MULTIPLY
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            fixed _Range;
            fixed4 _Color;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv) * _Color;
                clip(col.a - _Range);
                return col;
            }
            ENDCG
        }
    }
}
