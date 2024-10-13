(
    name: "Standard2DShader",

    properties: [
        (
            name: "diffuseTexture",
            kind: Sampler(default: None, fallback: White),
        ),
    ],

    passes: [
        (
            name: "Forward",
            draw_parameters: DrawParameters(
                cull_face: None,
                color_write: ColorMask(
                    red: true,
                    green: true,
                    blue: true,
                    alpha: true,
                ),
                depth_write: true,
                stencil_test: None,
                depth_test: true,
                blend: Some(BlendParameters(
                    func: BlendFunc(
                        sfactor: SrcAlpha,
                        dfactor: OneMinusSrcAlpha,
                        alpha_sfactor: SrcAlpha,
                        alpha_dfactor: OneMinusSrcAlpha,
                    ),
                    equation: BlendEquation(
                        rgb: Add,
                        alpha: Add
                    )
                )),
                stencil_op: StencilOp(
                    fail: Keep,
                    zfail: Keep,
                    zpass: Keep,
                    write_mask: 0xFFFF_FFFF,
                ),
            ),
            vertex_shader:
               r#"
                layout(location = 0) in vec3 vertexPosition;
                layout(location = 1) in vec2 vertexTexCoord;
                layout(location = 2) in vec4 vertexColor;

                uniform mat4 i3m_worldViewProjection;
                uniform mat4 i3m_worldMatrix;

                out vec2 texCoord;
                out vec4 color;
                out vec3 fragmentPosition;

                void main()
                {
                    texCoord = vertexTexCoord;
                    fragmentPosition = (i3m_worldMatrix * vec4(vertexPosition, 1.0)).xyz;
                    gl_Position = i3m_worldViewProjection * vec4(vertexPosition, 1.0);
                    color = vertexColor;
                }
               "#,

           fragment_shader:
               r#"
                uniform sampler2D diffuseTexture;

                uniform int i3m_lightCount;
                uniform vec4 i3m_lightsColorRadius[16]; // xyz - color, w = radius
                uniform vec3 i3m_lightsPosition[16];
                uniform vec3 i3m_lightsDirection[16];
                uniform vec2 i3m_lightsParameters[16]; // x = hotspot angle, y - full cone angle delta
                uniform vec4 i3m_ambientLightColor;

                out vec4 FragColor;

                in vec2 texCoord;
                in vec4 color;
                in vec3 fragmentPosition;

                void main()
                {
                    vec3 lighting = i3m_ambientLightColor.xyz;
                    for(int i = 0; i < i3m_lightCount; ++i) {
                        // "Unpack" light parameters.
                        float halfHotspotAngleCos = i3m_lightsParameters[i].x;
                        float halfConeAngleCos = i3m_lightsParameters[i].y;
                        vec3 lightColor = i3m_lightsColorRadius[i].xyz;
                        float radius = i3m_lightsColorRadius[i].w;
                        vec3 lightPosition = i3m_lightsPosition[i];
                        vec3 direction = i3m_lightsDirection[i];

                        // Calculate lighting.
                        vec3 toFragment = fragmentPosition - lightPosition;
                        float distance = length(toFragment);
                        vec3 toFragmentNormalized = toFragment / distance;
                        float distanceAttenuation = S_LightDistanceAttenuation(distance, radius);
                        float spotAngleCos = dot(toFragmentNormalized, direction);
                        float directionalAttenuation = smoothstep(halfConeAngleCos, halfHotspotAngleCos, spotAngleCos);
                        lighting += lightColor * (distanceAttenuation * directionalAttenuation);
                    }

                    FragColor = vec4(lighting, 1.0) * color * S_SRGBToLinear(texture(diffuseTexture, texCoord));
                }
               "#,
        )
    ],
)