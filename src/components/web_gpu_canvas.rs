use leptos::{html::Canvas, logging::log, prelude::*};
use std::iter;
use wasm_bindgen_futures::JsFuture;
use web_sys::{
    GpuAdapter, GpuCanvasConfiguration, GpuCanvasContext, GpuColorTargetState, GpuDevice,
    GpuFragmentState, GpuLoadOp, GpuRenderPassColorAttachment, GpuRenderPassDescriptor,
    GpuRenderPipelineDescriptor, GpuShaderModuleDescriptor, GpuStoreOp, GpuVertexState,
    js_sys::Array,
    wasm_bindgen::{JsCast, JsValue},
};

// This proof of concept is an adaption of the code from
// https://webgpufundamentals.org/webgpu/lessons/webgpu-fundamentals.html#a-drawing-triangles-to-textures,
// converted from JavaScript to Rust using web_sys.

#[component]
pub fn WebGpuCanvas(shader_source: &'static str) -> impl IntoView {
    log!("Shader: {}", shader_source);

    let canvas_ref = NodeRef::<Canvas>::new();

    Effect::new(move |_| {
        if let Some(canvas) = canvas_ref.get() {
            log!("value = {}", "hi");

            let gpu = web_sys::window().unwrap().navigator().gpu();
            if gpu.is_null_or_undefined() {
                log!("It seems this browser doesn't support WebGPU");
            } else {
                // To properly await this Promise, it must be converted to a Rust Future with
                // wasm_bindgen_futures::JsFuture::from. Then to use it within Leptos's reactive
                // system, it must be wrapped in a LocalResource. This creates a signal that can
                // trigger an Effect when the Promise resolves.
                let adapter = LocalResource::new(move || JsFuture::from(gpu.request_adapter()));

                Effect::new(move |_| {
                    if let Some(adapter) = adapter.get() {
                        // We have one more Promise to await.
                        let device = LocalResource::new(move || {
                            JsFuture::from(
                                adapter
                                    // TODO: Is this clone necessary?
                                    .clone()
                                    .unwrap()
                                    .dyn_into::<GpuAdapter>()
                                    .unwrap()
                                    .request_device(),
                            )
                        });

                        // TODO: Is this clone necessary?
                        let canvas_clone = canvas.clone();
                        Effect::new(move |_| {
                            if let Some(device) = device.get() {
                                let device = device.unwrap().dyn_into::<GpuDevice>().unwrap();

                                let context = canvas_clone
                                    .get_context("webgpu")
                                    .unwrap()
                                    .unwrap()
                                    .dyn_into::<GpuCanvasContext>()
                                    .unwrap();

                                let presentation_format = web_sys::window()
                                    .unwrap()
                                    .navigator()
                                    .gpu()
                                    .get_preferred_canvas_format();
                                let canvas_configuration =
                                    GpuCanvasConfiguration::new(&device, presentation_format);
                                context.configure(&canvas_configuration).unwrap();

                                let module_descriptor =
                                    GpuShaderModuleDescriptor::new(shader_source);
                                module_descriptor.set_label("Shaders for WebGPU test piece");
                                let module = device.create_shader_module(&module_descriptor);

                                let target = GpuColorTargetState::new(presentation_format);
                                let targets = Array::from_iter(iter::once(target));

                                let layout = JsValue::from_str("auto");
                                let vertex_state = GpuVertexState::new(&module);
                                let fragment_state = GpuFragmentState::new(&module, &targets);
                                let pipeline_descriptor =
                                    GpuRenderPipelineDescriptor::new(&layout, &vertex_state);
                                pipeline_descriptor.set_fragment(&fragment_state);
                                let pipeline =
                                    device.create_render_pipeline(&pipeline_descriptor).unwrap();

                                let color_attachment = GpuRenderPassColorAttachment::new(
                                    GpuLoadOp::Clear,
                                    GpuStoreOp::Store,
                                    &context
                                        .get_current_texture()
                                        .unwrap()
                                        .create_view()
                                        .unwrap(),
                                );
                                color_attachment.set_clear_value(&Array::from_iter(
                                    [
                                        JsValue::from_f64(0.3),
                                        JsValue::from_f64(0.3),
                                        JsValue::from_f64(0.3),
                                        JsValue::from_f64(1.0),
                                    ]
                                    .iter(),
                                ));
                                let color_attachments =
                                    Array::from_iter(iter::once(color_attachment));
                                let render_pass_descriptor =
                                    GpuRenderPassDescriptor::new(&color_attachments);
                                render_pass_descriptor
                                    .set_label("Render pass for WebGPU test piece");

                                let encoder = device.create_command_encoder();
                                encoder.set_label("Encoder for WebGPU test piece");

                                let pass =
                                    encoder.begin_render_pass(&render_pass_descriptor).unwrap();
                                pass.set_pipeline(&pipeline);
                                pass.draw(3);
                                pass.end();

                                let command_buffer = encoder.finish();
                                let command_buffers = Array::from_iter(iter::once(command_buffer));
                                device.queue().submit(&command_buffers);
                            }
                        });
                    }
                });
            }
        }
    });

    view! { <canvas node_ref=canvas_ref /> }
}
