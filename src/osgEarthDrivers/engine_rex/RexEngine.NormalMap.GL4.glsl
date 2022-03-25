#pragma include RexEngine.GL4.glsl
#pragma vp_function oe_rex_normalMapVS, vertex_view, 0.5

#pragma import_defines(OE_TERRAIN_RENDER_NORMAL_MAP)

out vec3 oe_normal_binormal;

#ifdef OE_TERRAIN_RENDER_NORMAL_MAP
uint64_t oe_terrain_getNormalHandle();
vec2 oe_terrain_getNormalCoords();
flat out uint64_t oe_normal_handle;
out vec2 oe_normal_uv;
#endif

void oe_rex_normalMapVS(inout vec4 unused)
{
    // send the bi-normal to the fragment shader
    oe_normal_binormal = normalize(gl_NormalMatrix * vec3(0,1,0));

#ifdef OE_TERRAIN_RENDER_NORMAL_MAP
    oe_normal_uv = oe_terrain_getNormalCoords();
    oe_normal_handle = oe_terrain_tex[oe_tile[oe_tileID].normalIndex];
#endif
}


[break]
#pragma include RexEngine.GL4.glsl
#pragma vp_function oe_rex_normalMapFS, fragment_coloring, 0.1

#pragma import_defines(OE_TERRAIN_RENDER_NORMAL_MAP)
#pragma import_defines(OE_DEBUG_NORMALS)
#pragma import_defines(OE_DEBUG_CURVATURE)



in vec3 vp_Normal;
in vec3 oe_UpVectorView;
in vec3 oe_normal_binormal;

#ifdef OE_TERRAIN_RENDER_NORMAL_MAP
vec4 oe_terrain_getNormalAndCurvature(in uint64_t, in vec2); // SDK
flat in uint64_t oe_normal_handle;
in vec2 oe_normal_uv;
#endif

// stage global
mat3 oe_normalMapTBN;

void oe_rex_normalMapFS(inout vec4 color)
{
    vec3 tangent = normalize(cross(oe_normal_binormal, oe_UpVectorView));
    oe_normalMapTBN = mat3(tangent, oe_normal_binormal, oe_UpVectorView);

#ifdef OE_TERRAIN_RENDER_NORMAL_MAP
    vec4 normalAndCurvature = oe_terrain_getNormalAndCurvature(oe_normal_handle, oe_normal_uv);
    vp_Normal = normalize( oe_normalMapTBN*normalAndCurvature.xyz );

#ifdef OE_DEBUG_CURVATURE
    // visualize curvature quantized:
    color.rgba = vec4(0, 0, 0, 1);
    float curvature = normalAndCurvature.w;
    if (curvature > 0.0) color.r = curvature;
    if (curvature < 0.0) color.g = -curvature;
#endif

#ifdef OE_DEBUG_NORMALS
    // visualize normals:
    color.rgb = (normalAndCurvature.xyz + 1.0)*0.5;
#endif

#endif // OE_TERRAIN_RENDER_NORMAL_MAP
}
