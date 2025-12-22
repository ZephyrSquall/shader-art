use leptos::prelude::*;
use leptos_router::components::A;

pub mod bubbleblight;
pub mod eclipse_of_the_sun;
pub mod forest_of_seasons;
pub mod guardian_of_dreams;
pub mod ocean_encounter;
pub mod stormy_flight;
pub mod test;
pub mod the_tree_elder;

// Some of my shader art ran just fine locally on my computer, but lag heavily once adapted to run
// in the browser. They are most likely written inefficiently as they were among the first shaders
// I've ever written. I may come back to them and try to optimize them so they can run without lag
// in the browser. But for now, I have disabled routing to the laggy shader arts.
#[component]
pub fn Gallery() -> impl IntoView {
    view! {
        <p>"This is a gallery."</p>
        <A href="/">"Go to home"</A>
        <br />
        <A href="/test">"Go to test piece"</A>
        <br />
        <A href="/ocean-encounter">"Go to Ocean Encounter"</A>
        // <br />
        // <A href="/the-tree-elder">"Go to The Tree Elder"</A>
        <br />
        <A href="/eclipse-of-the-sun">"Go to Eclipse of the Sun"</A>
        <br />
        <A href="/guardian-of-dreams">"Go to Guardian of Dreams"</A>
        <br />
        <A href="/bubbleblight">"Go to Bubbleblight"</A>
        <br />
        <A href="/stormy-flight">"Go to Stormy Flight"</A>
        // <br />
        // <A href="/forest-of-seasons">"Go to Forest of Seasons"</A>
        <br />
    }
}
