defmodule Wallet do
  @version <<0>>
  @checkSumLen 4
  defstruct private_key: nil, public_key: nil

  def new_wallet(%Wallet{} = w) do
    {public_key, private_key} =
      :crypto.generate_key(
        :ecdh,
        :secp256k1
      )

    %{w | private_key: private_key, public_key: public_key}
  end

  def get_address(%Wallet{} = w) do
    versioned_payload = @version ++ :crypto.hash(:ripemd160, :crypto.hash(:sha256, w.public_key))

    checksum =
      Enum.slice(:crypto.hash(:sha256, :crypto.hash(:sha256, versioned_payload)), 0, @checkSumLen)

    Base.encode64(versioned_payload ++ checksum)
  end

  def hash_pub_key(pub_key) do
    :crypto.hash(:ripemd160, :crypto.hash(:sha256, pub_key))
  end
end
