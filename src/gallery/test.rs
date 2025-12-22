use crate::components::web_gl_2_canvas::WebGl2Canvas;
use leptos::prelude::*;
use leptos_router::components::A;

#[component]
pub fn Test() -> impl IntoView {
    view! {
        <h2>"Test piece"</h2>
        <A href="/gallery">"Back to gallery"</A>
        <br />
        <WebGl2Canvas
            vertex_shader_source=include_str!("../../shaders/test/vertex.glsl")
            fragment_shader_source=include_str!("../../shaders/test/fragment.glsl")
            image_sources=&["assets/watermark.png"]
            style:width="90vw"
            style:height="80vh"
        />
    }
}
