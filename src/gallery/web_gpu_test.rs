use crate::components::web_gpu_canvas::WebGpuCanvas;
use leptos::prelude::*;
use leptos_router::components::A;

#[component]
pub fn WebGpuTest() -> impl IntoView {
    view! {
        <h2>"WebGPU test piece"</h2>
        <A href="/gallery">"Back to gallery"</A>
        <br />
        <WebGpuCanvas
            shader_source=include_str!("../../shaders/web_gpu_test/shader.wgsl")
            style:width="90vw"
            style:height="80vh"
        />
    }
}
