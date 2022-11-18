use std::str::FromStr;
use sui_sdk::types::base_types::SuiAddress;
use sui_sdk::SuiClient;

#[tokio::main]
async fn main() -> Result<(), anyhow::Error> {
    let sui = SuiClient::new("https://fullnode.devnet.sui.io:443", None, None).await?;
    let address = SuiAddress::from_str("0x9e0c6a22c904817400a1dac9ec3e47ddebe97bc4")?;
    let objects = sui.read_api().get_objects_owned_by_address(address).await?;
    println!("{:?}", objects);

    // println!("{:#?}", sui.available_rpc_methods());

    Ok(())
}
