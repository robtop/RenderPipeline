/**
 *
 * RenderPipeline
 *
 * Copyright (c) 2014-2016 tobspr <tobias.springer1@gmail.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#version 430

%DEFINES%

#define USE_MAIN_SCENE_DATA
#pragma include "render_pipeline_base.inc.glsl"
#pragma include "includes/vertex_output.struct.glsl"
#pragma include "includes/material_output.struct.glsl"

in vec4 p3d_Vertex;
in vec3 p3d_Normal;
in vec2 p3d_MultiTexCoord0;

uniform mat4 p3d_ViewProjectionMatrix;

#if EXPERIMENTAL_PREV_TRANSFORM
uniform mat4 p3d_PrevModelViewMatrix;
#endif
uniform mat4 trans_model_to_world;
uniform mat3 tpose_world_to_model;

out layout(location=0) VertexOutput vOutput;
out layout(location=4) flat MaterialOutput mOutput;

uniform struct {
    vec4 baseColor;
    vec4 emission;
    float roughness;
    float metallic;
    float refractiveIndex;
} p3d_Material;

%INCLUDES%
%INOUT%

void main() {
    vOutput.texcoord = p3d_MultiTexCoord0;
    vOutput.normal = normalize(tpose_world_to_model * p3d_Normal).xyz;
    vOutput.position = (trans_model_to_world * p3d_Vertex).xyz;

    // TODO: We have to account for skinning, we can maybe use hardware skinning for this.
    #if EXPERIMENTAL_PREV_TRANSFORM
        vOutput.last_proj_position = p3d_PrevModelViewMatrix * p3d_Vertex;
    #else
        vOutput.last_proj_position = MainSceneData.last_view_proj_mat_no_jitter * (trans_model_to_world * p3d_Vertex);
    #endif

    // Get material properties
    mOutput.color          = p3d_Material.baseColor.xyz;
    mOutput.specular_ior   = p3d_Material.refractiveIndex;
    mOutput.metallic       = p3d_Material.metallic;
    mOutput.roughness      = p3d_Material.roughness;
    mOutput.normalfactor   = p3d_Material.emission.r;
    mOutput.translucency   = p3d_Material.emission.b;
    mOutput.transparency   = p3d_Material.baseColor.w;
    mOutput.emissive       = p3d_Material.emission.w;

    %VERTEX%

    gl_Position = p3d_ViewProjectionMatrix * vec4(vOutput.position, 1);

    %TRANSFORMATION%
}
