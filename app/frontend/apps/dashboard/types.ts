// The contract between the Rails controller and this app. Anything the server
// puts in `data-props` is declared here — if the Ruby side renames a key, the
// mismatch surfaces at the mount point rather than as an undefined at runtime.
export type DashboardProps = {
  accountName: string
  initialStep?: number
}

export type DraftForm = {
  name: string
  email: string
}
