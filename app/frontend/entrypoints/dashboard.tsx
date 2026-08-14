import { createRoot } from "react-dom/client"
import Dashboard from "../apps/dashboard/Dashboard"
import type { DashboardProps } from "../apps/dashboard/types"

// React page-apps mount once on a real page load. They are excluded from Turbo
// Drive (see the layout's turbo-visit-control meta), so there is no snapshot
// cache to restore and no unmount to coordinate.
const node = document.getElementById("dashboard-app")

if (!node) {
  throw new Error("dashboard entrypoint loaded on a page without #dashboard-app")
}

const props = JSON.parse(node.dataset.props || "{}") as DashboardProps

createRoot(node).render(<Dashboard {...props} />)
