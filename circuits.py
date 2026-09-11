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

