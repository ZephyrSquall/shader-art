use leptos::prelude::*;
use leptos_router::components::A;

pub mod ocean_encounter;
pub mod test;

#[component]
pub fn Gallery() -> impl IntoView {
    view! {
        <p>"This is a gallery."</p>
        <A href="/">"Go to home"</A>
        <br />
        <A href="/test">"Go to test piece"</A>
        <br />
        <A href="/ocean-encounter">"Go to Ocean Encounter"</A>
        <br />
    }
}
