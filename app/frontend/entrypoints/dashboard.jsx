import { createRoot } from "react-dom/client"
import Dashboard from "../apps/dashboard/Dashboard"

// React page-apps mount once on a real page load. They are excluded from Turbo
// Drive (see the layout's data-turbo-visit-control), so there is no snapshot
// cache to restore and no unmount to coordinate.
const node = document.getElementById("dashboard-app")
const props = JSON.parse(node.dataset.props || "{}")

createRoot(node).render(<Dashboard {...props} />)