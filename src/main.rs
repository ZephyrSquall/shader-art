use crate::gallery::Gallery;
use crate::gallery::{ocean_encounter::OceanEncounter, test::Test};
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
                <Route path=path!("test") view=Test />
                <Route path=path!("ocean-encounter") view=OceanEncounter />
            </Routes>
        </Router>
    }
}
