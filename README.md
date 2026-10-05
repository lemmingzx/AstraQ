# AstraQ

**An offline, AI-powered interactive quantum computing learning platform.**

AstraQ pairs a locally-running AI tutor with real quantum circuit execution, visual state exploration, a hands-on code environment, and a built-in assessment system — so learners can read an explanation, run an actual quantum circuit, see the result, visualize the quantum state, debug their own code, and test their understanding, all without an internet connection, a cloud API key, or any ongoing cost.

Built for Smart India Hackathon 2026, problem statement **SIH26140 — AI-Based Interactive Quantum Algorithm Learning Platform**. 🏆 1st place, Inter-College Internal Hackathon 2026.

---

## Why AstraQ

Most "AI tutor" projects wrap a chatbot around a subject and hope for the best. AstraQ takes a different approach:

- **Modular, grounded knowledge** — the AI is restricted to a specific topic file per course, rather than one giant mixed knowledge base. This keeps answers accurate and prevents the AI from drifting into unrelated or unverified territory.
- **Retrieval-Augmented Generation (RAG)** — real reference textbooks (both team-curated and user-uploaded) are chunked and indexed, with the most relevant passages retrieved live per question rather than dumping entire books into context.
- **Real quantum execution, not simulation of an idea** — every topic is backed by an actual Qiskit circuit run on a local simulator. Learners see genuine measurement results and real Bloch sphere visualizations, not canned output.
- **Verified code only — never AI-invented syntax** — the AI explains and reproduces real, tested code pulled directly from this project's own source files. Free-form AI code generation was deliberately disabled after testing showed it could hallucinate outdated, non-working syntax.
- **Fully offline** — the AI model runs locally via [Ollama](https://ollama.com), not a cloud API. No data leaves the device, no ongoing cost, no internet dependency once set up. This matters for accessible education in low-connectivity regions.
- **Rigorously tested, honestly documented** — the team ran dozens of structured adversarial tests against the AI's own answers during development, finding and fixing real failure modes. Known limitations are disclosed in-app via an explicit AI warning, not hidden.
- **Open source, top to bottom** — every dependency is free and open source (see [Credits](#credits--open-source-notice) below), and AstraQ itself is released under the GPLv3.

---

## Features

- 📘 **Six topic-based courses** — What is a Quantum Computer?, Superposition, Entanglement, the Qiskit 4-step workflow, the Deutsch-Jozsa algorithm, and Hybrid Quantum-Classical ML (PennyLane) — each with its own isolated knowledge file.
- 🤖 **Local AI tutor, dual-model** — [Qwen 2.5 (7B)](https://huggingface.co/Qwen/Qwen2.5-7B-Instruct) is the default engine (tested as more reliable across harder topics), with [Phi-3-mini (3.8B)](https://huggingface.co/microsoft/Phi-3-mini-4k-instruct) available as a fast, lightweight fallback for lower-spec hardware — both served locally via Ollama.
- 📎 **RAG-powered reference material** — drop PDFs into an "Official" (team-curated) or "User-uploaded" library per topic; relevant excerpts are retrieved automatically via TF-IDF similarity search and cited by source.
- ⚛️ **Real Qiskit circuits** — Superposition, Bell-state entanglement, and both Deutsch-Jozsa oracle variants (constant/balanced) run on Qiskit's `AerSimulator`, with results rendered as a live bar chart.
- 🔮 **Bloch sphere visualization** — real quantum state visualization via Qiskit's own `Statevector` and `plot_bloch_multivector`, computed before measurement collapses the state.
- 💻 **Code Lab** — verified starter code templates, plus an AI-assisted debugger: paste your own circuit code, run it in an isolated subprocess (so a crash can't take down the main app), and get an explanation grounded in the real Python traceback produced.
- 🎨 **Visual Circuit Builder** — drag-and-drop gates (H, X) onto qubit wires, add a CNOT, and generate real, runnable Qiskit code live — copy it straight into Code Lab to execute.
- 📝 **Exam & Report Card** — hand-verified quiz questions per topic, automatic scoring, and a progress dashboard (session-based).
- 💬 **Context-aware Q&A** — the tutor remembers recent conversation turns, so natural follow-ups and corrections ("I mean X") work as expected.
- 🖥️ **One-command setup** — `setup.sh` installs the entire stack (Qiskit, Ollama, both AI models, Streamlit, RAG dependencies) and sets up a simple `astraq` launcher command plus a desktop application entry.
- 📜 **Built-in Setup Guide and Credits pages** — in-app, OS-aware setup instructions and full attribution for every open-source component used.

---

## Quick Start (Linux / Ubuntu)

```bash
git clone https://github.com/lemmingzx/AstraQ
cd AstraQ
chmod +x setup.sh
./setup.sh
```

Once setup finishes, open a **new terminal** and run:

```bash
astraq
```

AstraQ will open automatically in your browser. You can also launch it from your applications menu, where it appears as "AstraQ".

> **macOS / Windows:** this project's setup script and testing were done on Linux/Ubuntu only. See the official [Qiskit installation guide](https://quantum.cloud.ibm.com/docs/en/guides/install-qiskit) and [Ollama downloads](https://ollama.com/download) to set up the dependencies manually on other platforms, then follow the manual steps below.

---

## Manual Setup

If you'd rather set things up yourself instead of using `setup.sh`:

```bash
# 1. Create and activate a virtual environment
python3 -m venv .venv
source .venv/bin/activate

# 2. Install Qiskit and the local simulator
pip install 'qiskit>=1' qiskit-aer

# 3. Install Streamlit, the Ollama Python client, and RAG/visualization dependencies
pip install streamlit ollama pypdf scikit-learn matplotlib

# 4. Install Ollama (the local AI runtime)
curl -fsSL https://ollama.com/install.sh | sh

# 5. Pull the AI models (Qwen ~4.7GB, Phi-3 ~2.3GB, one-time download)
ollama pull qwen2.5:7b
ollama pull phi3:mini

# 6. Run AstraQ
streamlit run app.py
```

Make sure `app.py`, `circuits.py`, and all six course `.txt` files are in the same folder.

---

## Project Structure

```
AstraQ/
├── app.py                      # Streamlit app — all pages, AI logic, RAG, quiz data
├── circuits.py                  # Qiskit circuit definitions + execution
├── base_00.txt                  # Course: What is a Quantum Computer?
├── superposition.txt            # Course: Superposition
├── entanglement.txt             # Course: Entanglement
├── qiskit_workflow.txt          # Course: The Qiskit 4-step programming pattern
├── deutsch_jozsa.txt            # Course: The Deutsch-Jozsa algorithm
├── pennylane_hybrid.txt         # Course: Hybrid Quantum-Classical ML (PennyLane)
├── pdf_library/
│   ├── official/<course-name>/  # Team-curated reference PDFs (read-only in-app)
│   └── user/<course-name>/      # User-uploaded reference PDFs
├── setup.sh                     # One-command installer for Linux/Ubuntu
├── LICENSE                      # GPLv3
└── README.md
```

Adding a new topic means writing a new knowledge `.txt` file, adding an entry to the `COURSES` dict, and (optionally) a matching circuit function in `circuits.py` — the app's core architecture doesn't need to change.

---

## How It Works

1. **Pick a topic.** Only that topic's `.txt` file — plus the real, verified source code for its circuit function(s) — is loaded into the AI's context. This "modular course" design keeps answers scoped and accurate rather than pulling from one large, mixed knowledge base.
2. **Explain this topic** asks the local AI model to explain the concept, grounded strictly in that material.
3. **Run circuit** executes the actual Qiskit circuit for that topic on `AerSimulator` (1000 shots), displays the measurement counts as a bar chart, and asks the AI to interpret the specific result just produced.
4. **Show Bloch sphere** (where available) computes the real quantum statevector and renders it visually, before measurement collapses it.
5. **Ask a question** lets the learner ask anything about the current topic, with recent conversation history and any relevant RAG-retrieved reference excerpts included.
6. **Code Lab** lets learners get verified starter code or debug their own — execution happens in an isolated subprocess, and any error shown to the AI is a real Python traceback, never a guess.
7. **Circuit Builder** lets learners visually assemble a circuit and generates the equivalent real Qiskit code to run in Code Lab.
8. **Exam** tests understanding per topic with hand-verified questions; results are saved to the **Report Card**.

If a question falls outside the currently loaded topic's material, the AI is instructed to say so rather than answer from unverified general knowledge.

---

## Known Limitations

In the interest of the same honesty this project tries to model in its AI design, here's what AstraQ does *not* yet do well:

- **Deep theoretical nuance under broad questions** is weaker than factual/definitional recall — confirmed through structured testing (~60% reliability in this specific category vs. ~85% on grounded topic Q&A). The AI tends to answer more precisely when asked narrow, specific questions.
- **AI-assisted debugging is not 100% consistent** — testing found the same real error occasionally produced a correct diagnosis on one run and a hallucinated, incorrect one (referencing outdated Qiskit syntax) on another, even with the real traceback provided.
- **PennyLane support is conceptual only** — there is no live PennyLane circuit execution yet; it's covered as a knowledge topic, not a working integration.
- **Progress tracking is session-only**, not persistent across restarts.
- **Multi-qubit support in the visual Circuit Builder is capped at 2 qubits**, with CNOT added via a button rather than true drag-and-drop (a deliberate scope decision, not a bug).
- **Tested primarily on Linux/Ubuntu.** Client access (viewing the web UI) has been verified from Windows and Android over local network and Tailscale VPN, but the backend setup itself has not been tested on macOS or Windows.

These are tracked, not hidden — the application itself displays an AI accuracy disclaimer, and the team's own adversarial testing process is part of what the project is designed to demonstrate.

---

## Credits & Open Source Notice

AstraQ is built entirely on open-source software:

| Component | Purpose | License |
|---|---|---|
| [Qiskit](https://www.ibm.com/quantum/qiskit) | Quantum circuit construction & simulation | [Apache 2.0](https://www.apache.org/licenses/LICENSE-2.0) |
| [Ollama](https://ollama.com) | Local LLM runtime | [MIT](https://github.com/ollama/ollama/blob/main/LICENSE) |
| [Qwen 2.5 (7B)](https://huggingface.co/Qwen/Qwen2.5-7B-Instruct) (Alibaba Cloud) | Default AI tutor model | [Apache 2.0](https://www.apache.org/licenses/LICENSE-2.0) |
| [Phi-3-mini](https://huggingface.co/microsoft/Phi-3-mini-4k-instruct) (Microsoft) | Lightweight fallback AI model | [MIT](https://opensource.org/licenses/MIT) |
| [Streamlit](https://streamlit.io) | Web app framework | [Apache 2.0](https://github.com/streamlit/streamlit/blob/develop/LICENSE) |
| [pypdf](https://github.com/py-pdf/pypdf) | PDF text extraction for RAG | [BSD-3-Clause](https://github.com/py-pdf/pypdf/blob/main/LICENSE) |
| [scikit-learn](https://scikit-learn.org) | TF-IDF retrieval for RAG | [BSD-3-Clause](https://github.com/scikit-learn/scikit-learn/blob/main/COPYING) |
| [Matplotlib](https://matplotlib.org) | Bloch sphere rendering | [PSF/BSD-compatible](https://matplotlib.org/stable/users/project/license.html) |

**Reference material used for RAG / research:**
- *Quantum Computing for the Quantum Curious* — Hughes, Isaacson, Perry, Sun, Turner ([CC BY 4.0, open access](https://doi.org/10.1007/978-3-030-61601-4))
- *Introduction to Classical and Quantum Computing* — Thomas G. Wong
- *Hybrid Quantum-Classical Machine Learning with PennyLane* — Sidney Shapiro ([arXiv:2511.14786](https://arxiv.org/abs/2511.14786))

This attribution is also shown in-app under the **Credits** page.

---

## License

AstraQ is released under the **[GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0.html)**. See [`LICENSE`](./LICENSE) for the full text. You are free to use, study, modify, and redistribute this project under the same terms.

---

## Future Scope

Mapped directly against the official SIH26140 problem statement's expected deliverables:

- **Additional courses**: Grover's algorithm, QAOA, VQE, quantum teleportation
- **Real multi-framework execution**: PennyLane, Cirq, and qBraid backends (currently Qiskit Aer only)
- **Circuit diagram rendering**: visual gate-diagram display via Qiskit's native drawing tools
- **Raw statevector display**, alongside the existing Bloch sphere visualization
- **A distinct coding-challenge mode**: submit code, auto-check against an expected output (separate from the existing debug-your-own-code flow)
- **Persistent, cross-session progress tracking** and instructor dashboards
- **Real IBM Quantum hardware execution** (currently local simulation only, by design — free, fast, and noise-free for teaching)
- **User authentication**, for multi-user/institutional deployments

---

## Acknowledgements

Built for **Smart India Hackathon 2026**, problem statement SIH26140 — AI-Based Interactive Quantum Algorithm Learning Platform. 🏆 1st Place, Inter-College Internal Hackathon Round, Team Tech Quanta.
