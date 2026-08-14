export default function StepIndicator({ steps, current }) {
  return (
    <ol className="mt-4 flex gap-2 text-sm">
      {steps.map((label, index) => (
        <li
          key={label}
          data-active={index === current || undefined}
          className={
            index === current
              ? "rounded bg-indigo-600 px-2 py-1 text-white"
              : "rounded bg-slate-100 px-2 py-1 text-slate-600"
          }
        >
          {label}
        </li>
      ))}
    </ol>
  )
}