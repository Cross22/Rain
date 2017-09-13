using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Assertions;

public class MakeItRain : MonoBehaviour {
    public Texture srcTexture;
    public RenderTexture massTexture;
    public Material massTextureMaterial;
    void Start()
    {
        Assert.IsNotNull(srcTexture);
        Assert.IsNotNull(massTextureMaterial);
        Assert.IsNotNull(massTextureMaterial.mainTexture as RenderTexture);

        Graphics.Blit(srcTexture, massTextureMaterial.mainTexture as RenderTexture);
    }

    void Update()
    {
        var tempTexture = RenderTexture.GetTemporary(massTexture.descriptor);
        
        {
            Graphics.Blit(massTexture, tempTexture, massTextureMaterial);
            Graphics.Blit(tempTexture, massTexture, massTextureMaterial);
        }
        RenderTexture.ReleaseTemporary(tempTexture);
    }
}
