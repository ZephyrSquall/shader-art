use crate::components::web_gl_2_canvas::WebGl2Canvas;
use leptos::prelude::*;
use leptos_router::components::A;

#[component]
pub fn EclipseOfTheSun() -> impl IntoView {
    view! {
        <h2>"Eclipse of the Sun"</h2>
        <A href="/gallery">"Back to gallery"</A>
        <br />
        <WebGl2Canvas
            vertex_shader_source=include_str!("../../shaders/eclipse_of_the_sun/vertex.glsl")
            fragment_shader_source=include_str!("../../shaders/eclipse_of_the_sun/fragment.glsl")
            image_sources=&[
                "assets/eclipse_of_the_sun/darken.png",
                "assets/eclipse_of_the_sun/static.png",
                "assets/eclipse_of_the_sun/glow.png",
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
