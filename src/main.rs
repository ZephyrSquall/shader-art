use leptos::{html::Canvas, logging::log, prelude::*};
use std::{cell::RefCell, rc::Rc};
use web_sys::{
    js_sys,
    wasm_bindgen::{prelude::Closure, JsCast},
    WebGl2RenderingContext,
};

fn main() {
    console_error_panic_hook::set_once();
    leptos::mount::mount_to_body(App)
}

#[component]
fn App() -> impl IntoView {
    log!("Starting!");

    let vertex_shader_source = r##"#version 300 es

        in vec4 position;

        void main() {
            gl_Position = position;
        }
        "##;
    let fragment_shader_source = r##"#version 300 es

        precision highp float;

        uniform vec2 u_resolution;
        uniform float u_time;
        
        out vec4 outColor;

        void main() {
            vec2 image_uv = gl_FragCoord.xy / u_resolution.xy;
            vec2 uv = image_uv * 2.0 - 1.0;

            vec4 color = vec4(uv.x, uv.y, sin(u_time), 1.0);
            outColor = color;
        }
        "##;
    log!("Vertex shader: {}", vertex_shader_source);
    log!("Fragment shader: {}", fragment_shader_source);

    let test_canvas_ref = NodeRef::<Canvas>::new();

    Effect::new(move |_| {
        // Get the HtmlCanvasElement (canvas) and the WebGl2RenderingContext (gl)
        if let Some(canvas) = test_canvas_ref.get() {
            log!("value = {}", "hi");
            let gl = canvas
                .get_context("webgl2")
                .unwrap()
                .unwrap()
                .dyn_into::<WebGl2RenderingContext>()
                .unwrap();

            // Compile vertex shader
            let vertex_shader = gl
                .create_shader(WebGl2RenderingContext::VERTEX_SHADER)
                .unwrap();
            gl.shader_source(&vertex_shader, vertex_shader_source);
            gl.compile_shader(&vertex_shader);

            let vertex_success = gl
                .get_shader_parameter(&vertex_shader, WebGl2RenderingContext::COMPILE_STATUS)
                .as_bool()
                .unwrap();
            log!("vertex shader compilation success: {}", vertex_success);

            // Compile fragment shader
            let fragment_shader = gl
                .create_shader(WebGl2RenderingContext::FRAGMENT_SHADER)
                .unwrap();
            gl.shader_source(&fragment_shader, fragment_shader_source);
            gl.compile_shader(&fragment_shader);

            let fragment_success = gl
                .get_shader_parameter(&fragment_shader, WebGl2RenderingContext::COMPILE_STATUS)
                .as_bool()
                .unwrap();
            log!("fragment shader compilation success: {}", fragment_success);

            // Create the program
            let program = gl.create_program().unwrap();
            gl.attach_shader(&program, &vertex_shader);
            gl.attach_shader(&program, &fragment_shader);
            gl.link_program(&program);
            gl.use_program(Some(&program));

            // Set the input vertices
            let buffer = gl.create_buffer();
            gl.bind_buffer(WebGl2RenderingContext::ARRAY_BUFFER, buffer.as_ref());

            let vertices: [f32; 12] = [
                -1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, 1.0, -1.0, -1.0, 1.0, -1.0,
            ];

            unsafe {
                let buffer_view = js_sys::Float32Array::view(&vertices);
                gl.buffer_data_with_array_buffer_view(
                    WebGl2RenderingContext::ARRAY_BUFFER,
                    &buffer_view,
                    WebGl2RenderingContext::STATIC_DRAW,
                );
            }

            let vao = gl
                .create_vertex_array()
                .ok_or("Could not create vertex array object")
                .unwrap();
            gl.bind_vertex_array(Some(&vao));

            let position = gl.get_attrib_location(&program, "position");
            gl.vertex_attrib_pointer_with_i32(
                position.try_into().unwrap(),
                2,
                WebGl2RenderingContext::FLOAT,
                false,
                0,
                0,
            );
            gl.enable_vertex_attrib_array(position.try_into().unwrap());

            // Set resolution uniform
            let resolution_uniform_location = gl.get_uniform_location(&program, "u_resolution");
            gl.uniform2f(
                resolution_uniform_location.as_ref(),
                canvas.width() as f32,
                canvas.height() as f32,
            );

            // Set time uniform
            let time_uniform_location = gl.get_uniform_location(&program, "u_time");
            gl.uniform1f(time_uniform_location.as_ref(), 0.0);

            // Draw
            let vertices_count = (vertices.len() / 2) as i32;

            let draw_frame = Rc::new(RefCell::new(None::<Closure<dyn FnMut()>>));
            let draw_first_frame = draw_frame.clone();

            *draw_first_frame.borrow_mut() = Some(Closure::new(move || {
                let milliseconds_elapsed = web_sys::window().unwrap().performance().unwrap().now();
                log!(
                    "Hi from draw_frame! milliseconds_elapsed: {}",
                    milliseconds_elapsed
                );

                gl.viewport(0, 0, canvas.width() as i32, canvas.height() as i32);
                gl.clear_color(0.0, 0.0, 0.0, 1.0);
                gl.clear(WebGl2RenderingContext::COLOR_BUFFER_BIT);
                gl.uniform1f(
                    time_uniform_location.as_ref(),
                    (milliseconds_elapsed * 0.001) as f32,
                );
                gl.draw_arrays(WebGl2RenderingContext::TRIANGLES, 0, vertices_count);

                web_sys::window()
                    .unwrap()
                    .request_animation_frame(
                        draw_frame
                            .borrow()
                            .as_ref()
                            .unwrap()
                            .as_ref()
                            .unchecked_ref(),
                    )
                    .unwrap();
            }));
            web_sys::window()
                .unwrap()
                .request_animation_frame(
                    draw_first_frame
                        .borrow()
                        .as_ref()
                        .unwrap()
                        .as_ref()
                        .unchecked_ref(),
                )
                .unwrap();
        }
    });

    view! {
        <p>
            "This is a test of a browser-based GLSL renderer. If it works, a box below should be drawn using your computer's GPU, which is initially green, yellow, black, and red, and periodically flashes blue. This box should also scale itself if you change the window size."
        </p>
        <canvas node_ref=test_canvas_ref style:width="90vw" style:height="80vh"></canvas>
    }
}
