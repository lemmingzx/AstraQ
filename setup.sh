#!/bin/bash
# ==========================================================
# AstraQ Setup Script — Linux / Ubuntu
# Installs Qiskit, Ollama + phi3:mini, Streamlit, and AstraQ
# itself, then sets up a one-word launcher command.
# Licensed under GPLv3 — see LICENSE in the AstraQ repository.
# ==========================================================

set -e

INSTALL_DIR="$HOME/AstraQ"
BIN_DIR="$HOME/.local/bin"

echo "=================================================="
echo " AstraQ Setup"
echo " Installing to: $INSTALL_DIR"
echo "=================================================="

if [[ "$(uname)" != "Linux" ]]; then
    echo "This script is written and tested for Linux/Ubuntu only."
    echo "For other operating systems, see:"
    echo "  Qiskit: https://quantum.cloud.ibm.com/docs/en/guides/install-qiskit"
    echo "  Ollama: https://ollama.com/download"
    exit 1
fi

mkdir -p "$INSTALL_DIR"
mkdir -p "$BIN_DIR"

echo ""
echo "[1/8] Writing AstraQ project files..."

cat > "$INSTALL_DIR/app.py" <<'ASTRAQ_EOF'
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


cat > "$INSTALL_DIR/circuits.py" <<'ASTRAQ_EOF'
from qiskit import QuantumCircuit
from qiskit_aer import AerSimulator

def superposition_demo():
    qc = QuantumCircuit(1, 1)
    qc.h(0)
    qc.measure(0, 0)
    return qc

def bell_state_demo():
    qc = QuantumCircuit(2, 2)
    qc.h(0)
    qc.cx(0, 1)
    qc.measure([0, 1], [0, 1])
    return qc

def run_circuit(qc, shots=1000):
    sim = AerSimulator()
    job = sim.run(qc, shots=shots)
    result = job.result()
    counts = result.get_counts()
    return counts

if __name__ == "__main__":
    print("Superposition results:", run_circuit(superposition_demo()))
    print("Bell state (entanglement) results:", run_circuit(bell_state_demo()))

ASTRAQ_EOF

cat > "$INSTALL_DIR/base_00.txt" <<'ASTRAQ_EOF'
Modern computing is built on transistors — tiny switches controlling electron flow to represent binary bits (0 or 1). As manufacturers shrink transistors toward atomic scale, quantum effects like tunneling (electrons passing through barriers they classically shouldn't) start interfering with reliable operation, pushing chip designers toward new architectures.

Quantum computers take a different approach entirely, built on two core quantum properties:

Superposition: Unlike a classical bit, a qubit can exist in a combination of 0 and 1 states at once. Adding qubits grows the number of representable states exponentially, enabling certain kinds of massive parallel computation.

Entanglement: Two or more qubits can become correlated such that measuring one instantly tells you something about the other's state, even at a distance. Importantly, this cannot be used to send information faster than light — the correlation is real, but using it still requires a classical communication channel. Entanglement is a resource for computation and cryptography, not a communication shortcut.

Quantum computers won't replace everyday devices — they excel at specific problems: searching unsorted data faster (Grover's algorithm, roughly square-root time vs. classical), threatening current encryption by efficiently solving problems like integer factorization (Shor's algorithm), and simulating quantum systems directly — useful for drug discovery and materials science, since classical computers struggle to simulate quantum nature itself.

ASTRAQ_EOF

cat > "$INSTALL_DIR/superposition.txt" <<'ASTRAQ_EOF'
Topic: Superposition

A classical bit is always either 0 or 1. A qubit, the basic unit of quantum information, can exist in a combination of the 0 and 1 states at the same time — this is called superposition. It is not that the qubit is "secretly" one or the other and we just don't know which; it genuinely exists in both possibilities until it is measured.

The Hadamard gate (H gate) is the standard way to put a qubit into an equal superposition. Starting from state |0>, applying an H gate produces a state that has a 50% chance of measuring as 0 and a 50% chance of measuring as 1. This is exactly what the accompanying circuit demonstrates: a single qubit, an H gate, then a measurement, run 1000 times, producing roughly a 50/50 split between '0' and '1'.

Superposition is important because it is the foundation of quantum parallelism: with more qubits in superposition together, a quantum computer can represent an exponentially large number of states simultaneously, which certain algorithms (like Grover's search) exploit for speedups over classical computers. Superposition by itself does not make a computer faster — it's the combination with specific quantum algorithms that provides the advantage.

Common misconception to avoid: superposition does not mean "fast random guessing" or "trying every answer at once for free." The power comes from carefully designed algorithms that use interference between the superposed states to amplify correct answers and cancel out wrong ones.

ASTRAQ_EOF

cat > "$INSTALL_DIR/entanglement.txt" <<'ASTRAQ_EOF'
Topic: Entanglement

Entanglement is a quantum phenomenon where two or more qubits become correlated such that the measurement outcome of one qubit is directly linked to the outcome of the other, no matter how far apart they are physically separated.

The simplest entangled state is called a Bell state. It is created by putting one qubit into superposition with a Hadamard (H) gate, then applying a CNOT (controlled-NOT) gate using that qubit as the control and a second qubit as the target. The result is a state where measuring the two qubits together always gives matching outcomes: either both are 0, or both are 1 — you should essentially never see one qubit read 0 and the other read 1 for this particular circuit.

This matches exactly what the accompanying circuit demonstrates: running the Bell state circuit 1000 times produces results clustering almost entirely around '00' and '11', with '01' and '10' appearing rarely or not at all. That strong correlation, appearing even though each individual qubit's own result still looks random, is the signature of entanglement.

Important and commonly misunderstood point: entanglement does NOT allow faster-than-light communication. You cannot use it to send a message instantly across a distance. The correlation is real, but to actually compare or use the results meaningfully, you still need to communicate the measurement outcomes through a normal classical channel (radio, internet, etc.), which is bounded by the speed of light. Entanglement is a resource for computation and secure communication protocols, not a way to bypass physics.

Entanglement, combined with superposition, is what gives quantum computers their unique computational structure — qubits are not just individually uncertain, they can be jointly and inseparably linked.

ASTRAQ_EOF

cat > "$INSTALL_DIR/qiskit_workflow.txt" <<'ASTRAQ_EOF'
Topic: How Qiskit Programs Are Structured (The Four-Step Pattern)

What is Qiskit: Qiskit is an open-source quantum computing software framework, originally developed by IBM, written in Python. It lets programmers build quantum circuits, run them on local simulators (which run on an ordinary computer with no quantum hardware involved) or on real IBM quantum processors accessed over the internet, and analyze the results. It's one of the most widely used tools for learning and doing practical quantum programming, precisely because it supports both free local simulation and real hardware within the same framework.

Every Qiskit program, no matter how complex, follows the same basic four-step pattern. Understanding this pattern matters more than memorizing syntax, because it explains *why* code is organized the way it is.

Step 1 — Map the problem:
This means turning whatever you're trying to solve into an actual quantum circuit. For example, if you want to demonstrate superposition, you "map" that idea into a circuit with one qubit and a Hadamard gate. If you want entanglement, you map it into two qubits with a Hadamard gate and a CNOT gate. In the code you've already written, this step is the superposition_demo() and bell_state_demo() functions — they literally build the QuantumCircuit object.

Step 2 — Optimize (called "transpilation"):
Before a circuit can run, it sometimes needs to be rewritten into a form the specific backend (simulator or real hardware) can actually execute — different backends support different basic gates, so Qiskit can automatically convert your circuit into an equivalent one using only the gates that backend understands. For a simple local simulator like the one used in this project (AerSimulator), this step happens automatically behind the scenes and doesn't need to be done manually. It becomes much more important when running on real quantum hardware, which has strict physical limitations.

Step 3 — Execute:
This is running the circuit and collecting results. In the code already written, this is the run_circuit() function — it takes a circuit, runs it a set number of times ("shots," here 1000), and returns how often each outcome occurred. Running many shots matters because quantum measurement is probabilistic: a single run only gives one random outcome, but many shots reveal the underlying probability pattern (like the 50/50 split for superposition).

Step 4 — Post-process:
This means taking the raw results and turning them into something meaningful — printing them, plotting them as a chart, or interpreting what they mean. In this project, this is done by printing the counts dictionary, and separately, by displaying it as a bar chart and having the AI tutor explain what the result demonstrates.

Why this matters for this project: every course topic (superposition, entanglement, and any future topic) follows this exact same four-step shape: build a small circuit (map), run it on the local simulator (optimize + execute happen automatically), then show and explain the result (post-process). This is the repeatable pattern the whole platform is built on — new topics just mean writing a new circuit-building function and a new explanation file, not reinventing the workflow.

Note on real quantum hardware: real IBM quantum computers exist and can run these same circuits, but they introduce extra complexity — physical noise, error rates, and techniques like resilience levels and dynamical decoupling to reduce that noise. This project intentionally uses only local simulation (AerSimulator), which behaves ideally with no noise, since it's simpler, free, and sufficient for teaching the core concepts. Real hardware execution is a natural "future scope" extension, not something needed for the current build.

ASTRAQ_EOF


echo "[2/8] Setting up Python virtual environment..."
cd "$INSTALL_DIR"
if ! python3 -m venv .venv 2>/tmp/astraq_venv_err; then
    echo "venv creation failed, attempting to install python3-venv..."
    PYVER=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
    sudo apt update
    sudo apt install -y "python3-venv" "python${PYVER}-venv" || true
    python3 -m venv .venv
fi
source .venv/bin/activate

echo "[3/8] Upgrading pip..."
pip install --upgrade pip --quiet

echo "[4/8] Installing Qiskit + simulator..."
pip install 'qiskit>=1' qiskit-aer --quiet

echo "[5/8] Installing Streamlit + Ollama Python client..."
pip install streamlit ollama --quiet

echo "[6/8] Checking for Ollama runtime..."
if ! command -v ollama &> /dev/null; then
    echo "Ollama not found, installing..."
    curl -fsSL https://ollama.com/install.sh | sh
else
    echo "Ollama already installed, skipping."
fi

echo "[7/8] Pulling AI model (phi3:mini, ~2.3GB, one-time download)..."
ollama pull phi3:mini

echo "[8/8] Setting up the 'astraq' launcher command..."

cat > "$INSTALL_DIR/run.sh" <<'ASTRAQ_EOF'
#!/bin/bash
cd "$HOME/AstraQ"
source .venv/bin/activate
streamlit run app.py
ASTRAQ_EOF
chmod +x "$INSTALL_DIR/run.sh"

ln -sf "$INSTALL_DIR/run.sh" "$BIN_DIR/astraq"
chmod +x "$BIN_DIR/astraq"

# Also add a desktop menu entry, if a desktop environment is present
DESKTOP_DIR="$HOME/.local/share/applications"
if [[ -d "$HOME/.local/share" ]]; then
    mkdir -p "$DESKTOP_DIR"
    cat > "$DESKTOP_DIR/astraq.desktop" <<DESKTOP_EOF
[Desktop Entry]
Name=AstraQ
Comment=AI Quantum Tutor
Exec=$INSTALL_DIR/run.sh
Terminal=true
Type=Application
Categories=Education;Science;
DESKTOP_EOF
fi

echo ""
echo "=================================================="
echo " AstraQ setup complete!"
echo "=================================================="
echo ""
echo "To start AstraQ, either:"
echo "  1. Open a NEW terminal and type: astraq"
echo "  2. Or find 'AstraQ' in your applications menu"
echo ""
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo "NOTE: $BIN_DIR is not in your PATH."
    echo "Add this line to your ~/.bashrc, then restart your terminal:"
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
fi
echo ""
