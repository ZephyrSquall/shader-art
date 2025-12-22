use crate::components::web_gl_2_canvas::WebGl2Canvas;
use leptos::prelude::*;
use leptos_router::components::A;

#[component]
pub fn OceanEncounter() -> impl IntoView {
    view! {
        <h2>"Ocean Encounter"</h2>
        <A href="/gallery">"Back to gallery"</A>
        <br />
        <WebGl2Canvas
            vertex_shader_source=include_str!("../../shaders/ocean_encounter/vertex.glsl")
            fragment_shader_source=include_str!("../../shaders/ocean_encounter/fragment.glsl")
            image_sources=&["assets/ocean_encounter/image.png", "assets/watermark.png"]
            canonical_width=1080
            canonical_height=1080
            style:width="auto"
            style:height="80vh"
            style:aspect-ratio="1/1"
        />
    }
}
