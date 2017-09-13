Shader "RainMassUpdate"
{
	Properties
	{
        _Fraction("Fraction", Range(0,1)) = 0.00001
		_MainTex ("Mass Texture", 2D) = "white" {}
        _AffinityTex("Affinity Texture", 2D) = "white" {}
	}
	SubShader
	{
		LOD 100

		Pass
		{
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
			};

			sampler2D _MainTex;
            float4 _MainTex_TexelSize; // texel distance in UV units
			float4 _MainTex_ST;
            sampler2D _AffinityTex;


			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;// TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
            /*
            half frag(v2f i) : SV_Target
            {
                float2 uvCurr = i.uv;
                float2 uvTop  = i.uv + float2(0, _MainTex_TexelSize.y);
                float curr = tex2D(_MainTex, uvCurr);
                float top  = tex2D(_MainTex, uvTop);

                float newVal = curr - 0.5f*curr + 0.5f*top;
                return saturate(newVal);
            }*/

                
            float random(float2 p)
            {
                float2 K1 = float2(
                    23.14069263277926, // e^pi (Gelfond's constant)
                    2.665144142690225 // 2^sqrt(2) (Gelfondâ€“Schneider constant)
                );
                return frac(cos(dot(p, K1)) * 12345.6789);
            }

			half frag (v2f i) : SV_Target
			{
                float2 uvCurr = i.uv;
                float2 uvTop = i.uv + float2(0, _MainTex_TexelSize.y);

                float currMass = tex2D(_MainTex, uvCurr);
                float topMass  = tex2D(_MainTex, uvTop );
                
                float currFrac = tex2D(_AffinityTex, uvCurr);
                float topFrac = tex2D(_AffinityTex, uvTop);

                float massLost = (currMass * currFrac);
                float massGained = (topMass * topFrac);
                currMass = saturate(currMass + massGained - massLost);
                return currMass;
			}
			ENDCG
		}
	}
}
