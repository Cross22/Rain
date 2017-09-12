Shader "UI/RainFinal"
{
	Properties
	{
		_MainTex ("NormalMap", 2D) = "white" {}
        _ExtraSample("ExtraSample", Range(0,1)) = 0
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
                half3  lightDir : TEXCOORD1;
                float2 uv : TEXCOORD0;
			};

            float _ExtraSample;
			sampler2D _MainTex;
            float4 _MainTex_TexelSize; // texel distance in UV units
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.lightDir = _WorldSpaceLightPos0.xyz;
				return o;
			}

            half3 NormalInWorldSpace(v2f i)
            {
            // For normap map:
//                half3 normal = UnpackNormal(tex2D(_MainTex, i.uv));
//                normal.z *= -1;

                half3 normal;

                if (_ExtraSample < 1)
                {
                half value = tex2D(_MainTex, i.uv).b;
                normal = half3( -ddx(value), -ddy(value), -1.0f);
                } else {
//                half value = tex2D(_MainTex, i.uv).b;
//                half valueR = tex2D(_MainTex, i.uv + float2(_MainTex_TexelSize.x,0)).b;
//                half valueB = tex2D(_MainTex, i.uv - float2(0,_MainTex_TexelSize.y)).b;
//                normal = half3( valueR-value, valueB-value, -1.0f);
                }

                return normalize(normal);
            }



			half4 frag (v2f i) : SV_Target
			{
				// sample the texture
				half3 normal = NormalInWorldSpace(i);
//                return half4(normal, 1.0f);
                half angle = max(0, dot(normal,i.lightDir));
				return half4(angle, angle, angle,  1.0f);
			}
			ENDCG
		}
	}
}
