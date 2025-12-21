use crate::components::web_gl_2_canvas::WebGl2Canvas;
use leptos::prelude::*;

#[component]
pub fn OceanEncounter() -> impl IntoView {
    view! {
        <WebGl2Canvas
            vertex_shader_source=include_str!("../../assets/ocean_encounter/vertex.glsl")
            fragment_shader_source=include_str!("../../assets/ocean_encounter/fragment.glsl")
            image_sources=&["assets/ocean_encounter/image.png", "assets/watermark.png"]
            style:width="auto"
            style:height="95vh"
            style:aspect-ratio="1/1"
        />
    }
}
