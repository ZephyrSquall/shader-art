use leptos::prelude::*;
use leptos_router::components::A;

#[component]
pub fn Home() -> impl IntoView {
    view! {
        <p>"This is a home page."</p>
        <A href="gallery">"Go to gallery"</A>
    }
}
