defmodule OutputTransaction do
  # 
  # 
  defstruct value: nil, script_pub_key: nil

  def can_be_unlocked_with(%OutputTransaction{} = outx, unlocking_data) do
    outx.script_pub_key === unlocking_data
  end
end
