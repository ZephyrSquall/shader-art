use leptos::{html::Canvas, logging::log, prelude::*};
use std::{cell::RefCell, rc::Rc};
use web_sys::{
    js_sys,
    wasm_bindgen::{prelude::Closure, JsCast},
    HtmlImageElement, WebGl2RenderingContext,
};

#[component]
pub fn WebGl2Canvas(
    vertex_shader_source: &'static str,
    fragment_shader_source: &'static str,
    image_sources: &'static [&'static str],
    // "Canonical width/height" is the width in pixels of a "good" view of the canvas. In most
    // cases, these are the same width and height that I used to record a video of the shader art.
    // This differs from the size the canvas will actually be rendered at; that gets controlled by
    // CSS properties. Setting the "canonical" values is important because by default, the canvas's
    // internal height and width are set to really low values, which causes images to be displayed
    // in very low resolution.
    canonical_width: u32,
    canonical_height: u32,
) -> impl IntoView {
    log!("Vertex shader: {}", vertex_shader_source);
    log!("Fragment shader: {}", fragment_shader_source);

    let images = image_sources
        .iter()
        .map(|image_source| {
            let image = HtmlImageElement::new().unwrap();
            image.set_src(image_source);
            image
        })
        .collect::<Vec<_>>();

    let canvas_ref = NodeRef::<Canvas>::new();

    Effect::new(move |_| {
        // Get the HtmlCanvasElement (canvas) and the WebGl2RenderingContext (gl)
        if let Some(canvas) = canvas_ref.get() {
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
                // SAFETY: No memory allocations are made before buffer_view is dropped, so the
                // underlying buffer won't change and invalidate the view while the view exists.
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

            // Set resolution uniform (also set canvas to canonical width/height to prevent image
            // blurriness)
            canvas.set_width(canonical_width);
            canvas.set_height(canonical_height);
            let resolution_uniform_location = gl.get_uniform_location(&program, "u_resolution");
            gl.uniform2f(
                resolution_uniform_location.as_ref(),
                canvas.width() as f32,
                canvas.height() as f32,
            );

            // Set time uniform
            let time_uniform_location = gl.get_uniform_location(&program, "u_time");
            gl.uniform1f(time_uniform_location.as_ref(), 0.0);

            // Set image-related uniforms (u_tex[N] and u_tex[N]Resolution)
            gl.pixel_storei(WebGl2RenderingContext::UNPACK_FLIP_Y_WEBGL, 1);

            for (index, image) in images.iter().enumerate() {
                let texture = gl.create_texture();
                gl.active_texture(WebGl2RenderingContext::TEXTURE0 + index as u32);
                gl.bind_texture(WebGl2RenderingContext::TEXTURE_2D, texture.as_ref());

                gl.tex_parameteri(
                    WebGl2RenderingContext::TEXTURE_2D,
                    WebGl2RenderingContext::TEXTURE_WRAP_S,
                    WebGl2RenderingContext::CLAMP_TO_EDGE as i32,
                );
                gl.tex_parameteri(
                    WebGl2RenderingContext::TEXTURE_2D,
                    WebGl2RenderingContext::TEXTURE_WRAP_T,
                    WebGl2RenderingContext::CLAMP_TO_EDGE as i32,
                );
                gl.tex_parameteri(
                    WebGl2RenderingContext::TEXTURE_2D,
                    WebGl2RenderingContext::TEXTURE_MIN_FILTER,
                    WebGl2RenderingContext::NEAREST as i32,
                );
                gl.tex_parameteri(
                    WebGl2RenderingContext::TEXTURE_2D,
                    WebGl2RenderingContext::TEXTURE_MAG_FILTER,
                    WebGl2RenderingContext::NEAREST as i32,
                );

                let mip_level = 0;
                let internal_format = WebGl2RenderingContext::RGBA;
                let src_format = WebGl2RenderingContext::RGBA;
                let src_type = WebGl2RenderingContext::UNSIGNED_BYTE;

                let tex_uniform_location =
                    gl.get_uniform_location(&program, format!("u_tex{index}").as_str());
                gl.uniform1i(tex_uniform_location.as_ref(), index as i32);

                let tex_resolution_uniform_location =
                    gl.get_uniform_location(&program, format!("u_tex{index}Resolution").as_str());

                let image_clone = image.clone();
                let gl_clone = gl.clone();
                let image_loaded_callback = Closure::<dyn FnMut()>::new(move || {
                    gl_clone.active_texture(WebGl2RenderingContext::TEXTURE0 + index as u32);
                    gl_clone.tex_image_2d_with_i32_and_i32_and_i32_and_format_and_type_and_html_image_element(
                        WebGl2RenderingContext::TEXTURE_2D,
                        mip_level,
                        internal_format as i32,
                        image_clone.natural_width() as i32,
                        image_clone.natural_height() as i32,
                        0,
                        src_format,
                        src_type,
                        &image_clone,
                    ).unwrap();

                    gl_clone.uniform2f(
                        tex_resolution_uniform_location.as_ref(),
                        image_clone.natural_width() as f32,
                        image_clone.natural_height() as f32,
                    );
                });
                image.set_onload(Some(image_loaded_callback.as_ref().unchecked_ref()));
                image_loaded_callback.forget();
            }

            // Draw
            let vertices_count = (vertices.len() / 2) as i32;

            let draw_frame = Rc::new(RefCell::new(None::<Closure<dyn FnMut()>>));
            let draw_first_frame = draw_frame.clone();

            // Closure that will call itself repeatedly to draw each frame.
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

                // Only call the next frame if the canvas element still exists. This closure would
                // otherwise call itself forever even after the canvas is gone, causing a memory
                // leak.
                if canvas_ref.try_get_untracked().is_some() {
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
                }
            }));

            // Call the closure to draw the first frame.
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

    view! { <canvas node_ref=canvas_ref /> }
}
