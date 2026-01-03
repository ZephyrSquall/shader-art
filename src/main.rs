use crate::gallery::Gallery;
use crate::gallery::{
    bubbleblight::Bubbleblight, eclipse_of_the_sun::EclipseOfTheSun,
    forest_of_seasons::ForestOfSeasons, guardian_of_dreams::GuardianOfDreams,
    ocean_encounter::OceanEncounter, stormy_flight::StormyFlight, the_tree_elder::TheTreeElder,
    web_gl_2_test::WebGl2Test, web_gpu_test::WebGpuTest,
};
use crate::home::Home;
use leptos::prelude::*;
use leptos_router::{
    components::{Route, Router, Routes},
    path,
};

mod components;
mod gallery;
mod home;

fn main() {
    console_error_panic_hook::set_once();
    leptos::mount::mount_to_body(App)
}

#[component]
fn App() -> impl IntoView {
    view! {
        <Router>
            <Routes fallback=|| "Page not found.">
                <Route path=path!("/") view=Home />
                <Route path=path!("gallery") view=Gallery />
                <Route path=path!("webgl2-test") view=WebGl2Test />
                <Route path=path!("webgpu-test") view=WebGpuTest />
                <Route path=path!("ocean-encounter") view=OceanEncounter />
                <Route path=path!("the-tree-elder") view=TheTreeElder />
                <Route path=path!("eclipse-of-the-sun") view=EclipseOfTheSun />
                <Route path=path!("guardian-of-dreams") view=GuardianOfDreams />
                <Route path=path!("bubbleblight") view=Bubbleblight />
                <Route path=path!("stormy-flight") view=StormyFlight />
                <Route path=path!("forest-of-seasons") view=ForestOfSeasons />
            </Routes>
        </Router>
    }
}
