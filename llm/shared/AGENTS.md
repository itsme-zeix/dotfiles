# Working agreement

- **Ask, don't assume:** If intent, requirements, or architecture are unclear, ask before changing files. When running unattended, choose a reasonable interpretation, proceed, and state the assumption.
- **Keep scope focused:** Don't change unrelated code. Surface problems you notice as separate issues rather than fixing them without approval.
- **Be clear about uncertainty:** Say what you don't know. When useful, run a small, low-risk experiment and report what it showed.
- **Suggest better approaches:** Offer an alternative when it has a meaningful long-term benefit. Explain the tradeoff, but don't expand the task without approval.

## How to approach code changes

- **Minimize reader load:** Keep the path through the code short and changing state local. Remove layers that merely pass work along.
- **Laziness protocol:** Use the simplest solution that fully solves the problem. Before adding a helper, option, or layer, ask what it simplifies now—not what it might help with someday.
- **Subtract before you add:** When replacing an approach, remove the old path where safe. Don't maintain two ways to do the same thing without a real need.
- **Fix root causes:** Reproduce a bug when practical, trace why it happens, and fix the cause rather than hiding the symptom.
- **Boundary discipline:** Check external input where it enters the program. Pass checked values onward instead of repeating the same checks throughout the code.
- **Model the domain:** If conditions or flags must stay in sync, reconsider how the data is represented. Add a new structure only when it removes repeated decisions or invalid combinations.
- **Make operations idempotent:** Design commands that change files or system state to be safe to rerun, including after an interrupted run. Preserve user data when recovering.

Apply these principles where relevant to the requested change, not as a reason to refactor unrelated code.
