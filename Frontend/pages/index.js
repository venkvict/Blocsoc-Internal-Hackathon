import styles from "@/styles/Home.module.css";
import {abi} from "../constants/abi"
import { useRef, useState } from "react";
import { ethers } from "ethers";

export default function Home() {

  const [isConnected, setIsConnected] = useState(false);
  const [signer, setSigner] = useState();

  const mintpoints= useRef();
  const merchname = useRef();

  const contractAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
  let points,merchName;
  const [mintForm, setMintForm] = useState(false);

  async function connect() {
    if(typeof window.ethereum !== "undefined"){
      try{
        await ethereum.request({method: "eth_requestAccounts"});
        setIsConnected(true);
        let connectedProvider = new ethers.providers.Web3Provider(window.ethereum);
        setSigner(connectedProvider.getSigner)
      }catch(e){
        console.log(e)
      }
  }else{
    setIsConnected(false)
  }}

  async function handleMintSubmit(){
    console.log("handleMintSubmit")
    points = mintpoints.current.value;
    merchName = merchname.current.value;
    console.log(points,merchName);
    const contract = new ethers.Contract(contractAddress, abi, signer);
    console.log(contract)
    await contract.mintNft(points,merchName);
  }
  

  return (
    <div> 
      {isConnected?(
      <>
        <p>Connected!</p>
        <button onClick={()=>setMintForm(!mintForm)}>Mint</button>
        {mintForm && <div>
          <label htmlFor="mintPoints">Points: </label>
          <input type="number" id="mintPoints" name="mintPoints" ref={mintpoints} placeholder="Enter Points"></input><br></br>
          <label htmlFor="mintPoints">Product Name/Description: </label>
          <input type ="text" id="mintDesc" name="mintDesc" ref={merchname} placeholder="Enter Name"></input><br></br>
          <button id="mintSubmit" onClick={() => {handleMintSubmit()}}> Submit</button>
        </div>}
      </>
      ):(
        <button onClick={() => connect()}>Connect</button>
      )
    }
    </div>
  );
}
