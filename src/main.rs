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
            "This is a test of displaying shader art in the browser, running on the user's GPU. If it works, a scene depicting a creature in the ocean should be shown below."
        </p>
        <WebGl2Canvas
            vertex_shader_source=include_str!("test.vert")
            fragment_shader_source=include_str!("ocean_encounter.frag")
            image_sources=&["image.png", "watermark.png"]
            style:width="auto"
            style:height="95vh"
            style:aspect-ratio="1/1"
        />
    }
}
