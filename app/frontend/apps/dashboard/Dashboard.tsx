import { useState } from "react"
import StepIndicator from "./StepIndicator"
import type { DashboardProps, DraftForm } from "./types"

const STEPS = [ "Account", "Details", "Review" ]

export default function Dashboard({ accountName, initialStep = 0 }: DashboardProps) {
  const [ step, setStep ] = useState(initialStep)
  const [ form, setForm ] = useState<DraftForm>({ name: "", email: "" })

  const update = (field: keyof DraftForm) => (event: React.ChangeEvent<HTMLInputElement>) =>
    setForm({ ...form, [field]: event.target.value })

  return (
    <section data-testid="dashboard" className="w-full max-w-xl">
      <h2 className="text-xl font-semibold text-slate-900">{accountName}</h2>

      <StepIndicator steps={STEPS} current={step} />

      {step === 0 && (
        <label className="block mt-4">
          <span className="text-sm text-slate-700">Name</span>
          <input
            data-testid="name-input"
            value={form.name}
            onChange={update("name")}
            className="mt-1 w-full rounded border border-slate-300 px-3 py-2"
          />
        </label>
      )}

      {step === 1 && (
        <label className="block mt-4">
          <span className="text-sm text-slate-700">Email</span>
          <input
            data-testid="email-input"
            value={form.email}
            onChange={update("email")}
            className="mt-1 w-full rounded border border-slate-300 px-3 py-2"
          />
        </label>
      )}

      {step === 2 && (
        <dl data-testid="review" className="mt-4 text-sm text-slate-700">
          <dt className="font-medium">Name</dt>
          <dd data-testid="review-name">{form.name}</dd>
          <dt className="mt-2 font-medium">Email</dt>
          <dd data-testid="review-email">{form.email}</dd>
        </dl>
      )}

      <div className="mt-6 flex gap-2">
        <button
          data-testid="back"
          onClick={() => setStep((s) => Math.max(0, s - 1))}
          disabled={step === 0}
          className="rounded border border-slate-300 px-3 py-1.5 text-sm disabled:opacity-40"
        >
          Back
        </button>
        <button
          data-testid="next"
          onClick={() => setStep((s) => Math.min(STEPS.length - 1, s + 1))}
          disabled={step === STEPS.length - 1}
          className="rounded bg-indigo-600 px-3 py-1.5 text-sm text-white disabled:opacity-40"
        >
          Next
        </button>
      </div>
    </section>
  )
}
