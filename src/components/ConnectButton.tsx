import { useWeb3React } from '@web3-react/core';
import { InjectedConnector } from '@web3-react/injected-connector';
const MetaMask = new InjectedConnector({});

export default function ConnectButton() {
  const { activate } = useWeb3React();

  return (
    <div className="connect-wallet-container">
      <img src="https://media.giphy.com/media/8a8p6QKKDvdytJfqYf/giphy.gif" alt="HPB gif" />
      <button
        className="cta-button connect-wallet-button"
        onClick={() => {
          activate(MetaMask);
        }}
      >
        Connect Wallet
      </button>
    </div>
  );
}
