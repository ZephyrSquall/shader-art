use crate::components::web_gl_2_canvas::WebGl2Canvas;
use leptos::prelude::*;

#[component]
pub fn Test() -> impl IntoView {
    view! {
        <WebGl2Canvas
            vertex_shader_source=include_str!("../../assets/test/vertex.glsl")
            fragment_shader_source=include_str!("../../assets/test/fragment.glsl")
            image_sources=&["assets/watermark.png"]
            style:width="90vw"
            style:height="80vh"
        />
    }
}
