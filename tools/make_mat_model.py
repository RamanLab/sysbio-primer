"""Write data/e_coli_core.mat from data/e_coli_core.xml, using COBRApy.

The MATLAB examples read the .mat copy because the COBRA Toolbox needs a
compiled libSBML to read SBML, which is not available for every MATLAB
release. Rerun this script whenever the .xml file changes.
"""
from pathlib import Path

import cobra

data = Path(__file__).resolve().parents[1] / "data"
model = cobra.io.read_sbml_model(str(data / "e_coli_core.xml"))
cobra.io.save_matlab_model(model, str(data / "e_coli_core.mat"))
print(f"Wrote {data / 'e_coli_core.mat'}")
