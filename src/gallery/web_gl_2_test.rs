use crate::components::web_gl_2_canvas::WebGl2Canvas;
use leptos::prelude::*;
use leptos_router::components::A;

#[component]
pub fn WebGl2Test() -> impl IntoView {
    view! {
        <h2>"WebGL2 test piece"</h2>
        <A href="/gallery">"Back to gallery"</A>
        <br />
        <WebGl2Canvas
            vertex_shader_source=include_str!("../../shaders/web_gl_2_test/vertex.glsl")
            fragment_shader_source=include_str!("../../shaders/web_gl_2_test/fragment.glsl")
            image_sources=&["assets/watermark.png"]
            canonical_width=2998
            canonical_height=1025
            style:width="90vw"
            style:height="80vh"
        />
    }
}
