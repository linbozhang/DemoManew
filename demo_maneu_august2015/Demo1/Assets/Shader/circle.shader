Shader "Custom/circle" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Radius("Circle ",Range(0,100)) =20
		_SRadius("SCircle ",Range(0,100)) =20
		_antis("anti",Range(0.5,2)) = 1
		_firstPos("fpos",Vector) = (200,315,0,0)
		_linewid("linewid",Range(1,100)) = 50
		_mousePos("Mousepos",Vector) = (0.8,0.7,0,0)
	}
	SubShader {
		Tags { "RenderType"="Opaque" }

		Pass {
			Cull  Off
			Lighting Off
			AlphaTest off
			ZWrite Off
			ZTest Off
			Blend SrcAlpha OneMinusSrcAlpha  

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#include "UnityCG.cginc" 

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Radius;
			float _antis;
			float _linewid;
			float4  _firstPos;
			float4  _mousePos;
			float _SRadius;

            struct v2f
            {
                float4  vertex :POSITION ;//顶点坐标
                float2  texcoord :TEXCOORD0   ;//纹理坐标
                float4 compos:TEXCOORD1  ;
            };

			v2f vert(v2f  v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP,v.vertex );
				o.texcoord = TRANSFORM_TEX(v.texcoord , _MainTex);
				o.compos = ComputeScreenPos(o.vertex );
				return  o;

			}

			float getAlpha(float2 fpos,float2 target,float rad)
			{
				float dis = max(0, length(fpos -target)- rad);
				float t =lerp(0,_antis,dis);
				return min(1,t);
			}

			float getLineAlpha(float2 fpos,float2 target,float2 cur,float lineWid,float type)
			{
				float2 f2c = cur-fpos;
				float2 f2t = target-fpos;
				float2 mid = f2t * 0.5;
				float d =dot(f2c,f2t);
				float2 g1 =f2t *d/ dot(f2t,f2t);
				float tlen =length(f2t);
				float glen = length(g1) - tlen;
				if(d <0 || glen >0)
				{
					return 0;
				}

				float2 r= f2c -g1;
				float len = sqrt(dot(r, r));
				float output ;
				if(type  == 0)
				{
					float  n = 2 * abs(length(g1)- tlen * 0.5) / tlen;

					float minR = min(_Radius,_SRadius);
					float MaxR = max(_Radius,_SRadius);
					float temp  = min(pow(lineWid,n/4) *10,minR);

					output = temp- len;
				}
				else if(type ==1)
				{
					output = lineWid- len;
				}
				
				return  clamp( output,0,1);
			} 


			float4 frag(v2f o):COLOR 
			{
				float4  col =float4 (1,1,1,0);
				float2 screenPos  =  (o.compos.xy /o.compos.w) * _ScreenParams .xy;
				float4 texcol =tex2D(_MainTex,o.texcoord);

				float2  fpos = _firstPos.xy;
				float2  spos = _mousePos.xy;
				
				float t1 =getAlpha(fpos,screenPos,_Radius);
				float t2= getAlpha(spos,screenPos,_SRadius);
				float t3 = getLineAlpha(fpos,spos,screenPos,_linewid,_firstPos.z);

				col = lerp(col,texcol,t3);
				col = lerp(col,texcol,1-t1);
				col = lerp(col,texcol,1-t2);
				
				return  col;
			}
			ENDCG

		}


	} 
	FallBack "Diffuse"
}
