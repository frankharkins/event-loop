module Utils.Modal exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, stopPropagationOn)

import Carbon.Icons exposing (..)
import Json.Decode

view : Bool -> msg -> msg -> List (Html msg) -> Html msg
view isOpen closeMsg noOp children =
  div
    [ classList
      [ ("opacity-0 invisible", not isOpen)
      , ("absolute z-100 transition-all duration-250 top-0 left-0 w-screen h-screen bg-muted/50 flex justify-center items-center p-8", True)
      ]
    , onClick closeMsg
    ]
    [ div
      [ class "border-px border-title bg-bg p-8 rounded-[4px] max-w-[800px] max-h-full overflow-auto shadow-lg"
      , stopPropagationOn "click" (alwaysStopPropogation noOp)
      ]
      children
    ]

alwaysStopPropogation : msg -> Json.Decode.Decoder (msg, Bool)
alwaysStopPropogation msg =
    Json.Decode.map (\_ -> (msg, True)) (Json.Decode.succeed msg)
