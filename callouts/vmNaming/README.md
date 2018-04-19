# A few example scripts that demonstrate how to use the vmNaming callout.

Important: The vmNaming callout sets the VM name, NOT the hostname
on the VM itself, though often the cloud will automatically set the
hostname to match the VM name automatically.

- name.py
  - A complex naming scheme with different parts of the name reflecting
  different bits of data about the VM.
- name2.py
  - Another example with enhanced logging and illegal character
  stripping.
- vmname.sh
  - A simple example showing how to use the job and app tier names
  together with a UUID to generate an informative, unique name.