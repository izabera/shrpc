mux runs a command and packs its stdout/stderr/exit code into a single stream

the data can be arbitrary and it's packed unambiguously

demux reconstructs it

it's relatively fast, or at least it's probably fast enough (6.2mbps in bash)
![demo](https://github.com/user-attachments/assets/81d810ec-3a6a-4167-bdc9-fcdb6443a9eb)

granted, this didn't go over the network, but still
