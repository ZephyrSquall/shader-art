use leptos::{logging::log, prelude::*};
use web_gl_2_canvas::WebGl2Canvas;

mod web_gl_2_canvas;

fn main() {
    console_error_panic_hook::set_once();
    leptos::mount::mount_to_body(App)
}

#[component]
fn App() -> impl IntoView {
    log!("Starting!");

    view! {
        <p>
            "This is a test of a browser-based GLSL renderer. If it works, a box below should be drawn using your computer's GPU, which is initially green, yellow, black, and red, and periodically flashes blue. This box should also scale itself if you change the window size."
        </p>
        <WebGl2Canvas
            vertex_shader_source=include_str!("test.vert")
            fragment_shader_source=include_str!("test.frag")
            style:width="90vw"
            style:height="80vh"
        />
    }
}
