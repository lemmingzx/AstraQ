import streamlit as st
import ollama
from circuits import superposition_demo, bell_state_demo, run_circuit

MODEL = "phi3:mini"

COURSES = {
    "Superposition": {
        "file": "superposition.txt",
        "circuit_fn": superposition_demo,
        "result_label": "Superposition result (H gate on 1 qubit)",
    },
    "Entanglement": {
        "file": "entanglement.txt",
        "circuit_fn": bell_state_demo,
        "result_label": "Bell state result (entangled 2 qubits)",
    },
    "Qiskit Workflow": {
        "file": "qiskit_workflow.txt",
        "circuit_fn": bell_state_demo,
        "result_label": "Example circuit output (same Bell state, shown via the 4-step pattern)",
    },
}


def load_knowledge(path):
    with open(path, "r", encoding="utf-8") as f:
        return f.read()


def ask_tutor(question, knowledge, history=None):
    system_prompt = f"""You are a quantum computing tutor named AstraQ for beginners.
Only use the following material to answer. Explain simply and clearly, in plain
language and short paragraphs.

Strict rules:
- Answer ONLY the single question given to you. Do NOT invent additional
  questions, do NOT continue the conversation on your own, and do NOT write
  "You:" or "Tutor:" or any further dialogue after your answer. Stop as soon
  as your answer to the one question is complete.
- Do NOT write, invent, or output any code, even as an example, unless the
  material below explicitly contains that exact code.
- Do NOT use extended jokes, party metaphors, roleplay, or fictional framing.
  A brief, natural analogy is fine; a themed narrative is not.
- Do NOT introduce steps, functions, or facts not present in the material.
  This includes NOT naming other libraries, tools, or frameworks not
  mentioned in the material below, even if they are real and well known.
- The material below covers ONE specific topic. If the question asks about a
  DIFFERENT quantum computing concept not explained in this material (even if
  related), do NOT answer it from general knowledge. Instead say clearly that
  this topic isn't covered by the current course, and suggest switching to a
  different topic in the dropdown if one might cover it.
- Use the recent conversation below (if any) to understand what the user is
  referring to, e.g. corrections, typos, or follow-ups like "I mean X."

MATERIAL:
{knowledge}
"""
    messages = [{"role": "system", "content": system_prompt}]

    # Include recent conversation turns so follow-ups/corrections have context.
    # Capped to the last 3 exchanges to keep the prompt small for a local model.
    if history:
        for past_q, past_a in history[-3:]:
            messages.append({"role": "user", "content": past_q})
            messages.append({"role": "assistant", "content": past_a})

    messages.append({"role": "user", "content": question})

    response = ollama.chat(
        model=MODEL,
        messages=messages,
        options={
            "stop": ["\nYou:", "\nTutor:", "\nYou ", "You:"],
        },
    )
    return response["message"]["content"]


def render_tutor_page():
    st.title("AstraQ")
    st.caption("Runs fully offline — local AI model + real quantum circuit simulation")

    course_name = st.selectbox("Pick a topic", list(COURSES.keys()))
    course = COURSES[course_name]
    knowledge = load_knowledge(course["file"])

    if "history" not in st.session_state or st.session_state.get("current_course") != course_name:
        st.session_state.history = []
        st.session_state.current_course = course_name

    st.subheader("Explanation")
    if st.button("Explain this topic"):
        with st.spinner("AstraQ is Thinking..."):
            explanation = ask_tutor(
                f"Explain {course_name} to a beginner.", knowledge, st.session_state.history
            )
        st.session_state.history.append(("Explain this topic", explanation))

    st.subheader("Run the quantum circuit")
    if st.button("Run circuit"):
        counts = run_circuit(course["circuit_fn"]())
        st.write(course["result_label"])
        st.bar_chart(counts)
        with st.spinner("Interpreting result..."):
            interpretation = ask_tutor(
                f"The circuit for {course_name} was just run and gave these measurement counts: {counts}. "
                f"Briefly explain what this result shows and why it confirms the concept.",
                knowledge,
                st.session_state.history,
            )
        st.write(interpretation)

    st.subheader("Ask a question")
    question = st.text_input("Your question")
    if st.button("Ask") and question:
        with st.spinner("AstraQ is Thinking..."):
            answer = ask_tutor(question, knowledge, st.session_state.history)
        st.session_state.history.append((question, answer))

    if st.session_state.history:
        st.subheader("Conversation")
        for q, a in reversed(st.session_state.history):
            st.markdown(f"**You:** {q}")
            st.markdown(f"**AstraQ:** {a}")
            st.markdown("---")


def render_credits_page():
    st.title("Credits & Open Source Notice")
    st.caption("AstraQ is built entirely on open-source software.")

    st.markdown("### AI model")
    st.markdown(
        "- **[Phi-3-mini](https://huggingface.co/microsoft/Phi-3-mini-4k-instruct)** "
        "by Microsoft — licensed under the [MIT License](https://opensource.org/licenses/MIT). "
        "Runs locally via [Ollama](https://ollama.com), no cloud API, no internet connection required."
    )

    st.markdown("### Core software")
    st.markdown(
        "- **[Qiskit](https://www.ibm.com/quantum/qiskit)** by IBM — quantum circuit construction "
        "and simulation. Licensed under the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).\n"
        "- **[Ollama](https://ollama.com)** — local LLM runtime used to serve the AI tutor. "
        "Licensed under the [MIT License](https://github.com/ollama/ollama/blob/main/LICENSE).\n"
        "- **[Streamlit](https://streamlit.io)** — the web app framework powering this interface. "
        "Licensed under the [Apache License 2.0](https://github.com/streamlit/streamlit/blob/develop/LICENSE)."
    )

    st.markdown("### This project's license")
    st.markdown(
        "AstraQ itself is released under the "
        "**[GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0.html)**. "
        "Source code is freely available for anyone to use, study, modify, and redistribute "
        "under the same terms. See the `LICENSE` file in this project's repository for full terms."
    )

    st.markdown("### Why local, offline AI")
    st.markdown(
        "AstraQ deliberately runs its AI tutor locally rather than through a cloud API. "
        "No user data leaves the device, there is no ongoing cost, and the platform works "
        "without an internet connection — important for accessible, low-resource education."
    )


def render_setup_page():
    st.title("Setup Guide")
    st.caption("Get Qiskit and this AI tutor running from scratch")

    os_choice = st.radio("What operating system are you on?", ["Linux / Ubuntu", "macOS", "Windows"])

    if os_choice == "Linux / Ubuntu":
        st.markdown("### Setting up Qiskit on Linux / Ubuntu")
        st.markdown(
            "These are the exact steps this project was built and tested with. "
            "Run each command in a terminal, in order."
        )

        st.markdown("**1. Create a Python virtual environment**")
        st.code("python3 -m venv .venv\nsource .venv/bin/activate", language="bash")
        st.caption(
            "If this fails with an 'ensurepip is not available' error, install the venv "
            "package first, then retry: sudo apt install python3-venv (or python3.X-venv "
            "matching your Python version)"
        )

        st.markdown("**2. Install Qiskit and the local simulator**")
        st.code("pip install 'qiskit>=1' qiskit-aer", language="bash")

        st.markdown("**3. Verify the install**")
        st.code('python3 -c "import qiskit; print(qiskit.__version__)"', language="bash")
        st.caption("Should print a version starting with 1. or higher.")

        st.markdown("**4. Install Ollama (runs the local AI model)**")
        st.code("curl -fsSL https://ollama.com/install.sh | sh", language="bash")

        st.markdown("**5. Pull the AI model**")
        st.code("ollama pull phi3:mini", language="bash")
        st.caption("Lightweight (~2.3GB) and runs well even on modest GPUs (4GB VRAM or less).")

        st.markdown("**6. Install the remaining Python packages**")
        st.code("pip install streamlit ollama", language="bash")

        st.markdown("**7. Run AstraQ**")
        st.code("streamlit run app.py", language="bash")
        st.caption("Opens automatically in your browser at localhost:8501.")

        st.info(
            "Remember: run `source .venv/bin/activate` every time you open a new terminal "
            "for this project, or Python won't find Qiskit."
        )

    else:
        st.markdown(f"### Setting up Qiskit on {os_choice}")
        st.warning(
            f"This guide was written and tested on Linux/Ubuntu only. For {os_choice}, "
            "the general steps are similar (Python virtual environment, then pip install), "
            "but exact commands and common issues differ enough that we'd rather point you "
            "to IBM's official, actively maintained installation guide rather than risk giving "
            "you inaccurate instructions."
        )
        st.markdown(
            "**[Official Qiskit installation guide (all platforms)]"
            "(https://quantum.cloud.ibm.com/docs/en/guides/install-qiskit)**"
        )
        st.markdown(
            "For the local AI model, Ollama also supports macOS and Windows — see "
            "**[ollama.com/download](https://ollama.com/download)** for platform-specific installers."
        )


st.set_page_config(page_title="AstraQ", layout="centered")

page = st.sidebar.radio("Navigate", ["AstraQ", "Setup Guide", "Credits"])
if page == "AstraQ":
    render_tutor_page()
elif page == "Setup Guide":
    render_setup_page()
else:
    render_credits_page()

