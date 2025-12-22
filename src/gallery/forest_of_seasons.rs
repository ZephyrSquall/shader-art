use crate::components::web_gl_2_canvas::WebGl2Canvas;
use leptos::prelude::*;
use leptos_router::components::A;

#[component]
pub fn ForestOfSeasons() -> impl IntoView {
    view! {
        <h2>"Forest of Seasons"</h2>
        <A href="/gallery">"Back to gallery"</A>
        <br />
        <WebGl2Canvas
            vertex_shader_source=include_str!("../../shaders/forest_of_seasons/vertex.glsl")
            fragment_shader_source=include_str!("../../shaders/forest_of_seasons/fragment.glsl")
            image_sources=&[
                "assets/forest_of_seasons/sorei_other.png",
                "assets/forest_of_seasons/sorei_winter.png",
                "assets/forest_of_seasons/tree_summer.png",
                "assets/forest_of_seasons/tree_autumn.png",
                "assets/forest_of_seasons/tree_winter.png",
                "assets/forest_of_seasons/tree_spring.png",
                "assets/watermark.png",
            ]
            canonical_width=1200
            canonical_height=900
            style:width="auto"
            style:height="80vh"
            style:aspect-ratio="4/3"
        />
    }
}
