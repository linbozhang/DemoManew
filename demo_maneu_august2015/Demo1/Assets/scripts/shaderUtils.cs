using UnityEngine;
using System.Collections;

public class shaderUtils : MonoBehaviour {


	public MeshFilter mesh;
	public MeshRenderer render;
	public Material mat
	{
		get{
			return render.sharedMaterial;
		}
	}

	Vector3 down ;
	Vector3 up ;
	float rad ;

	bool moving=false;

	float mode =0f;
	// Use this for initialization
	void Start () 
	{
		down = mat.GetVector("_firstPos");
		up = mat.GetVector("_mousePos");
	}

	void OnGUI()
	{
		GUILayout.Space(10);
		GUILayout.BeginVertical();
		if(GUILayout.Button("直线"))
		{
			mode =1;
		}
		GUILayout.Space(10);
		if(GUILayout.Button("微曲线"))
		{
			mode =0;
		}

		GUILayout.EndVertical();
	}
	
	// Update is called once per frame
	void Update () 
	{
		var temp = Input.mousePosition;
		if( Input.GetMouseButtonDown(0) && !moving )
		{
			moving = true;
			down = new Vector3(temp.x,temp.y,mode);;
			mat.SetVector("_firstPos",down);
			rad = mat.GetFloat("_Radius");
				
		}
		if(moving)
		{
			mat.SetVector("_mousePos",temp);
			float delta = (Vector3.Distance(temp,down) * 2- rad )/150;
			float value = 0.63662f*  Mathf.Atan( delta);

			float frad =rad *(1-value);
			float fsrad =rad *value;
			float minrad = Mathf.Min(frad,fsrad)/2;

			mat.SetFloat("_Radius",frad);
			mat.SetFloat("_SRadius",fsrad);
			mat.SetFloat("_linewid",minrad);

			if(Input.GetMouseButtonUp(0) || value > 0.7f)
			{
				mat.SetFloat("_Radius",rad );
				moving = false;
				mat.SetVector("_firstPos",temp);
			}
		}




//		if( Input.simulateMouseWithTouches)
//		{
//
//			if(temp != down)
//			{
//				up =temp;
//
//
//				var delata = Vector3.Distance(up,down);
//			}
//				
//		}

	
	}
}
