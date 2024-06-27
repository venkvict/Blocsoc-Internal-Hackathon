import Head from "next/head";
import Image from "next/image";
import styles from "@/styles/Home.module.css";
import { useWeb3React } from "@web3-react/core";
import {InjectedConnector} from "@web3-react/injected-connector";
import {abi} from "../constants/abi"

const injected = new InjectedConnector(); 

export default function Home() {

  const { active, library:provider } = useWeb3React();

  const signer = provider.getSigner();
  const contractAddress = "";
  const contract = new ethers.Contract(contractAddress, abi, signer)

  async function connect()  {
    try{
      await activate(injected);
      let accounts = await provider.request({ method: "eth_requestAccounts" });
      let accountAddress = accounts[0];
    }catch(e){
      console.log("In connect function-index.js",e)
    }
  }

  async function mint() {
    if(active){
      try{
        contract.mintNft()
      }catch(e){
        console.log(e)
      }
    }
  }
  let button = False;

  return (
    <div> 
      if(active){
      <>
        <p>Connected!</p>
        <button onClick={button = True}>Mint</button>
        if(button){
          <form>
            <label for="mintPoints">Points: </label>
            <input type="number" id="mintPoints" name="mintPoints"></input>
            <input></input>
            <input type="submit" value="Submit"></input>
          </form>
        }
      </>
      }
      else{
        <button onClick={() => connect()}>Connect</button>
      }
    </div>
  );
}
