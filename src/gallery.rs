use crate::gallery::{ocean_encounter::OceanEncounter, test::Test};
use leptos::prelude::*;
use leptos_router::{
    components::{Outlet, ParentRoute, Route, A},
    path, MatchNestedRoutes,
};

mod ocean_encounter;
mod test;

#[component]
fn Gallery() -> impl IntoView {
    view! {
        <p>"This is a gallery."</p>
        <A href="/">"Go to home"</A>
        <br />
        <A href="test">"Go to test piece"</A>
        <br />
        <A href="ocean-encounter">"Go to Ocean Encounter"</A>
        <br />
        <Outlet />
    }
}

#[component(transparent)]
pub fn GalleryRoutes() -> impl MatchNestedRoutes + Clone {
    view! {
        <ParentRoute path=path!("/gallery") view=Gallery>
            <Route path=path!("") view=|| view! { <p>"Select a piece to view."</p> } />
            <Route path=path!("test") view=Test />
            <Route path=path!("ocean-encounter") view=OceanEncounter />
        </ParentRoute>
    }
    .into_inner()
}
