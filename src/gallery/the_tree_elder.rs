use crate::components::web_gl_2_canvas::WebGl2Canvas;
use leptos::prelude::*;
use leptos_router::components::A;

#[component]
pub fn TheTreeElder() -> impl IntoView {
    view! {
        <h2>"The Tree Elder"</h2>
        <A href="/gallery">"Back to gallery"</A>
        <br />
        <WebGl2Canvas
            vertex_shader_source=include_str!("../../shaders/the_tree_elder/vertex.glsl")
            fragment_shader_source=include_str!("../../shaders/the_tree_elder/fragment.glsl")
            image_sources=&["assets/the_tree_elder/image.png", "assets/watermark.png"]
            canonical_width=720
            canonical_height=720
            style:width="auto"
            style:height="80vh"
            style:aspect-ratio="1/1"
        />
    }
}
