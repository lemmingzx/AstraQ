import matplotlib
matplotlib.use("Agg")  # Force a non-interactive, GPU/GUI-free backend. This
                        # MUST happen before importing pyplot or anything that
                        # pulls it in (like qiskit's plotting tools) — without
                        # this, matplotlib may try to use a GUI/OpenGL backend,
                        # which can segfault in a headless/server context like
                        # this app, especially on some NVIDIA laptop setups.

from qiskit import QuantumCircuit
from qiskit_aer import AerSimulator
from qiskit.quantum_info import Statevector
from qiskit.visualization import plot_bloch_multivector

def superposition_demo():
    qc = QuantumCircuit(1, 1)
    qc.h(0)
    qc.measure(0, 0)
    return qc

def superposition_statevector_demo():
    # Same as superposition_demo() but with NO measurement, so the quantum
    # state is preserved (measurement would collapse it) — needed to plot
    # the Bloch sphere, which shows the state BEFORE it's measured.
    qc = QuantumCircuit(1)
    qc.h(0)
    return qc

def bell_state_demo():
    qc = QuantumCircuit(2, 2)
    qc.h(0)
    qc.cx(0, 1)
    qc.measure([0, 1], [0, 1])
    return qc

def bell_state_statevector_demo():
    # Same as bell_state_demo() but with no measurement, for Bloch sphere
    # plotting. Note: plotting each qubit individually here will show both
    # collapsed near the CENTER of their Bloch spheres — this is correct,
    # expected behavior, and is itself a real signature of entanglement:
    # each qubit alone has no definite state, even though the pair together
    # does. This is worth explaining live if you show this plot.
    qc = QuantumCircuit(2)
    qc.h(0)
    qc.cx(0, 1)
    return qc

def deutsch_jozsa_constant_demo():
    # 2 input qubits + 1 ancilla qubit. Oracle here is f(x) = 0 for all
    # inputs (constant) — implemented by doing nothing (identity), since
    # a function that never flips the ancilla is constant by definition.
    n = 2
    qc = QuantumCircuit(n + 1, n)
    qc.x(n)              # put ancilla into |1>
    qc.h(range(n + 1))   # superposition on all qubits
    # --- oracle: constant, does nothing ---
    qc.h(range(n))       # interference step on input qubits only
    qc.measure(range(n), range(n))
    return qc

def deutsch_jozsa_balanced_demo():
    # Same setup, but the oracle here is f(x) = x0 XOR x1 (balanced —
    # outputs 0 for exactly half of all possible inputs, 1 for the other
    # half), implemented as a CNOT from each input qubit to the ancilla.
    n = 2
    qc = QuantumCircuit(n + 1, n)
    qc.x(n)
    qc.h(range(n + 1))
    # --- oracle: balanced (XOR) ---
    for i in range(n):
        qc.cx(i, n)
    qc.h(range(n))
    qc.measure(range(n), range(n))
    return qc

def run_circuit(qc, shots=1000):
    sim = AerSimulator()
    job = sim.run(qc, shots=shots)
    result = job.result()
    counts = result.get_counts()
    return counts

def get_bloch_sphere_figure(qc_no_measurement):
    """Takes a circuit WITHOUT measurement (so the state is still 'live'),
    computes its statevector, and returns a matplotlib figure showing one
    Bloch sphere per qubit. Uses Qiskit's own built-in visualization
    function rather than anything custom, to keep this correct and verified."""
    state = Statevector.from_instruction(qc_no_measurement)
    return plot_bloch_multivector(state)

if __name__ == "__main__":
    print("Superposition results:", run_circuit(superposition_demo()))
    print("Bell state (entanglement) results:", run_circuit(bell_state_demo()))
