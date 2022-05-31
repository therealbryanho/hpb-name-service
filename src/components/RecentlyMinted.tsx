import { useWeb3React } from '@web3-react/core';

export type MintedProps = {
  mints: Array<any>;
  onEdit: (record: any) => void;
};

const CONTRACT_ADDRESS = '0x8f7fc7345b81fe3de6c4da19eb0fdf0d4dc52d80';
const tld = '.hpb';

export default function RecentlyMinted({ mints, onEdit }: MintedProps) {
  const { account } = useWeb3React();
  if (!account || mints.length === 0) return null;
  return (
    <div className="mint-container">
      <p className="subtitle"> Recently minted domains!</p>
      <div className="mint-list">
        {mints.map((mint, index) => {
          return (
            <div className="mint-item" key={index}>
              <div className="mint-row">
                <a
                  className="link"
                  href={`https://inft.io/assets/269/${CONTRACT_ADDRESS}/${mint.id}`}
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  <p className="underlined">
                    {mint.name}
                    {tld}
                  </p>
                </a>
                <button className="edit-button" onClick={() => onEdit(mint.name)}>
                  <img
                    className="edit-icon"
                    src="https://img.icons8.com/metro/26/000000/search.png"
                    alt="Edit button"
                  />
                </button>
              </div>
              <p> {mint.record} </p>
            </div>
          );
        })}
      </div>
    </div>
  );
}
