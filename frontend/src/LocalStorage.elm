module LocalStorage exposing (LocalStorageValue, decodeLocalStorage)

import Json.Decode as Decode

type alias LocalStorageValue = { key: String, value: String }

decodeLocalStorage : Decode.Decoder a -> String -> Result Decode.Error (Maybe a)
decodeLocalStorage decoder value =
  Decode.decodeString (Decode.nullable decoder) value
