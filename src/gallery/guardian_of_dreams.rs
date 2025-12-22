use crate::components::web_gl_2_canvas::WebGl2Canvas;
use leptos::prelude::*;
use leptos_router::components::A;

#[component]
pub fn GuardianOfDreams() -> impl IntoView {
    view! {
        <h2>"Guardian of Dreams"</h2>
        <A href="/gallery">"Back to gallery"</A>
        <br />
        <WebGl2Canvas
            vertex_shader_source=include_str!("../../shaders/guardian_of_dreams/vertex.glsl")
            fragment_shader_source=include_str!("../../shaders/guardian_of_dreams/fragment.glsl")
            image_sources=&[
                "assets/guardian_of_dreams/lines.png",
                "assets/guardian_of_dreams/background.png",
                "assets/watermark.png",
            ]
            canonical_width=1080
            canonical_height=1080
            style:width="auto"
            style:height="80vh"
            style:aspect-ratio="1/1"
        />
    }
}
