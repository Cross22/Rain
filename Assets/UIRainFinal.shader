Shader "UI/RainFinal"
{
	Properties
	{
		_MainTex ("NormalMap", 2D) = "white" {}
        _Tint("Tint", Color) = (0,0,0,0)
	}
	SubShader
	{
		Tags { "Queue"="Transparent" "RenderType"="Transparent" "IgnoreProjector"="True" }
		LOD 100

		Pass
		{
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha


			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float2 uvR : TEXCOORD1;
                float2 uvB : TEXCOORD2;
                half3  dirToLight : TEXCOORD4;
            };

			sampler2D _MainTex;
            float4 _MainTex_TexelSize; // texel distance in UV units
			float4 _MainTex_ST;
            float4 _Tint;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
                o.dirToLight = _WorldSpaceLightPos0.xyz;

				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uvR = o.uv - float2(_MainTex_TexelSize.x, 0);
                o.uvB = o.uv - float2(0, _MainTex_TexelSize.y);
				return o;
			}

            half4 NormalInWorldSpace(v2f i)
            {
            // For normap map:
//                half3 normal = UnpackNormal(tex2D(_MainTex, i.uv));
//                normal.z *= -1;

            // Finite differences with texel fetch
                half3 normal;
                half value = tex2D(_MainTex, i.uv);
                half valueR = tex2D(_MainTex, i.uvR);
                half valueB = tex2D(_MainTex, i.uvB);
                normal = half3( valueR-value, valueB-value, -1.0f);

                //half3 normal;
                //half value = tex2D(_MainTex, i.uv).b;
                //normal = half3( -ddx(value), -ddy(value), -1.0f);

                return half4(normalize(normal), value);
            }



			half4 frag (v2f i) : SV_Target
			{
				// sample the texture
				half4 normalAlpha = NormalInWorldSpace(i);

                half angle = max(0, dot(normalAlpha.xyz, i.dirToLight));
                half4 color = _Tint * angle;
                color.a = normalAlpha.a;
                return color;
			}
			ENDCG
		}
	}
}
