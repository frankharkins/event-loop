module Utils.PosixTime exposing (decode, encode)

import Time
import Json.Decode as Decode
import Json.Encode as Encode

decode : Decode.Decoder Time.Posix
decode =
  Decode.int
    |> Decode.andThen (Time.millisToPosix >> Decode.succeed)

encode : Time.Posix -> Encode.Value
encode time =
  time |> Time.posixToMillis |> Encode.int
