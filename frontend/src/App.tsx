import "./App.css";
import { useState } from "react";

export const CONTRACTS = {
  vtk: "0xD12b8be7D05c4F3A7EdA87841bFe69f2fA867aE1",
  vault: "0x10fB9EC2FbD4d2e95cd0D3D778610Cff5175345a",
};

function App() {
  return (
    <>
      <h1>Contract Addresses</h1>

      <p>VTK: {CONTRACTS.vtk}</p>
      <p>Vault: {CONTRACTS.vault}</p>
    </>
  );
}

export default App;
