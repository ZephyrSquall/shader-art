use crate::components::web_gl_2_canvas::WebGl2Canvas;
use leptos::prelude::*;
use leptos_router::components::A;

#[component]
pub fn Bubbleblight() -> impl IntoView {
    view! {
        <h2>"Bubbleblight"</h2>
        <A href="/gallery">"Back to gallery"</A>
        <br />
        <WebGl2Canvas
            vertex_shader_source=include_str!("../../shaders/bubbleblight/vertex.glsl")
            fragment_shader_source=include_str!("../../shaders/bubbleblight/fragment.glsl")
            image_sources=&[
                "assets/bubbleblight/tama.png",
                "assets/bubbleblight/sam.png",
                "assets/bubbleblight/sunlight.png",
                "assets/bubbleblight/moonlight.png",
                "assets/watermark.png",
            ]
            canonical_width=1200
            canonical_height=1050
            style:width="auto"
            style:height="80vh"
            style:aspect-ratio="8/7"
        />
    }
}
