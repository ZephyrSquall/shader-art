use crate::components::web_gl_2_canvas::WebGl2Canvas;
use leptos::prelude::*;
use leptos_router::components::A;

#[component]
pub fn StormyFlight() -> impl IntoView {
    view! {
        <h2>"Stormy Flight"</h2>
        <A href="/gallery">"Back to gallery"</A>
        <br />
        <WebGl2Canvas
            vertex_shader_source=include_str!("../../shaders/stormy_flight/vertex.glsl")
            fragment_shader_source=include_str!("../../shaders/stormy_flight/fragment.glsl")
            image_sources=&[
                "assets/stormy_flight/frame1.png",
                "assets/stormy_flight/frame2.png",
                "assets/stormy_flight/frame3.png",
                "assets/stormy_flight/frame4.png",
                "assets/watermark.png",
            ]
            canonical_width=1750
            canonical_height=1000
            style:width="auto"
            style:height="80vh"
            style:aspect-ratio="7/4"
        />
    }
}
