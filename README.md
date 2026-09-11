# AstraQ

**An offline, AI-powered quantum computing tutor.**

AstraQ pairs a locally-running AI tutor with real quantum circuit execution, so learners can read an explanation, run an actual quantum circuit, see the result, and ask follow-up questions — all without an internet connection, a cloud API key, or any cost.

Built for Smart India Hackathon 2026, problem statement **SIH26140 — AI-Based Interactive Quantum Algorithm Learning Platform**.

---

## Why AstraQ

Most "AI tutor" projects wrap a chatbot around a subject and hope for the best. AstraQ takes a different approach:

- **Modular, grounded knowledge** — the AI is restricted to a specific topic file per course (superposition, entanglement, the Qiskit workflow, etc.), rather than one giant knowledge base. This keeps answers accurate and prevents the AI from drifting into unrelated or unverified territory.
- **Real quantum execution, not simulation of an idea** — every topic is backed by an actual Qiskit circuit run on a local simulator. Learners see genuine measurement results (e.g. a real ~50/50 superposition split), not canned output.
- **Fully offline** — the AI model runs locally via [Ollama](https://ollama.com), not a cloud API. No data leaves the device, no ongoing cost, no internet dependency once set up. This matters for accessible education in low-connectivity settings.
- **Open source, top to bottom** — every dependency is free and open source (see [Credits](#credits--open-source-notice) below), and AstraQ itself is released under the GPLv3.

---

## Features

- 📘 **Topic-based courses** — each topic (currently Superposition, Entanglement, and the Qiskit 4-step workflow) has its own isolated knowledge file, keeping the AI's answers scoped and accurate.
- 🤖 **Local AI tutor** — powered by Microsoft's [Phi-3-mini](https://huggingface.co/microsoft/Phi-3-mini-4k-instruct) via Ollama, running entirely on-device.
- ⚛️ **Real Qiskit circuits** — superposition and Bell-state (entanglement) circuits run on Qiskit's `AerSimulator`, with results rendered as a live bar chart.
- 💬 **Context-aware Q&A** — the tutor remembers recent conversation turns, so natural follow-ups and corrections ("I mean X") work as expected.
- 🖥️ **One-command setup** — `setup.sh` installs everything (Qiskit, Ollama, the AI model, Streamlit) and sets up a simple `astraq` launcher command plus a desktop application entry.
- 📜 **Built-in Setup Guide and Credits pages** — in-app, OS-aware setup instructions and full attribution for every open-source component used.

---

## Quick Start (Linux / Ubuntu)

```bash
git clone https://github.com/lemmingzx/AstraQ
cd astraq
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

# 3. Install Streamlit and the Ollama Python client
pip install streamlit ollama

# 4. Install Ollama (the local AI runtime)
curl -fsSL https://ollama.com/install.sh | sh

# 5. Pull the AI model (~2.3GB, one-time download)
ollama pull phi3:mini

# 6. Run AstraQ
streamlit run app.py
```

Make sure `app.py`, `circuits.py`, and the four course `.txt` files (`base_00.txt`, `superposition.txt`, `entanglement.txt`, `qiskit_workflow.txt`) are all in the same folder.

---

## Project Structure

```
astraq/
├── app.py                 # Streamlit app — Tutor, Setup Guide, and Credits pages
├── circuits.py             # Qiskit circuit definitions (superposition, Bell state)
├── base_00.txt             # Foundational "why quantum computing" content
├── superposition.txt       # Course: Superposition
├── entanglement.txt        # Course: Entanglement
├── qiskit_workflow.txt     # Course: The Qiskit 4-step programming pattern
├── setup.sh                # One-command installer for Linux/Ubuntu
├── LICENSE                 # GPLv3
└── README.md
```

Adding a new topic means writing a new knowledge `.txt` file and (optionally) a matching circuit function — the app's architecture doesn't need to change.

---

## How It Works

1. **Pick a topic** from the dropdown. Only that topic's `.txt` file is loaded into the AI's context — this is the "modular course" design that keeps answers scoped and accurate rather than pulling from one large, mixed knowledge base.
2. **Explain this topic** asks the local AI model to explain the concept, grounded strictly in that file.
3. **Run circuit** executes the actual Qiskit circuit for that topic on `AerSimulator` (1000 shots), displays the measurement counts as a bar chart, and asks the AI to interpret the specific result just produced.
4. **Ask a question** lets the learner ask anything about the current topic, with recent conversation history included so follow-ups and corrections make sense.

If a question falls outside the currently loaded topic, the AI is instructed to say so rather than answer from unverified general knowledge.

---

## Credits & Open Source Notice

AstraQ is built entirely on open-source software:

| Component | Purpose | License |
|---|---|---|
| [Qiskit](https://www.ibm.com/quantum/qiskit) | Quantum circuit construction & simulation | [Apache 2.0](https://www.apache.org/licenses/LICENSE-2.0) |
| [Ollama](https://ollama.com) | Local LLM runtime | [MIT](https://github.com/ollama/ollama/blob/main/LICENSE) |
| [Phi-3-mini](https://huggingface.co/microsoft/Phi-3-mini-4k-instruct) (Microsoft) | The AI model powering the tutor | [MIT](https://opensource.org/licenses/MIT) |
| [Streamlit](https://streamlit.io) | Web app framework | [Apache 2.0](https://github.com/streamlit/streamlit/blob/develop/LICENSE) |

This attribution is also shown in-app under the **Credits** page.

---

## License

AstraQ is released under the **[GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0.html)**. See [`LICENSE`](./LICENSE) for the full text. You are free to use, study, modify, and redistribute this project under the same terms.

---

## Future Scope

- Additional courses: Deutsch-Jozsa, Grover's algorithm, quantum teleportation
- Circuit-mistake detection: let learners build their own simple circuits and have the AI point out errors
- Progress tracking across topics
- Optional support for running circuits on real IBM Quantum hardware (currently local simulation only, by design — free, fast, and noise-free for teaching)

---

## Acknowledgements

Built for **Smart India Hackathon 2026**, problem statement SIH26140.
