/* eslint-disable @typescript-eslint/ban-ts-comment */
import { useWeb3React } from '@web3-react/core';
import polygonLogo from '../assets/polygonlogo.png';
import hpbLogo from '../img/hpblogo.png';
import { networks } from '../utils/networks';

export default function ConnectionStatus() {
  const { account, chainId } = useWeb3React();

  return (
    <div className="flex-item justify-end">
      <img
        alt="Network logo"
        className="logo"
        src={
          //@ts-ignore
          networks[chainId?.toString(16)]?.includes('HPB Mainnet') ? polygonLogo : hpbLogo
        }
      />
      {account ? (
        <p>
          Wallet: {account.slice(0, 6)}...{account.slice(-4)}{' '}
        </p>
      ) : (
        <p> Not connected </p>
      )}
    </div>
  );
}
