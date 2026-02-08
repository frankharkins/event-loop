module Event exposing (Event, view)

import Html exposing (..)
import Time


-- type Msg
--   = Update Event
--   | Delete { id: String }

type alias Event =
  { name: String
  , id: String
  , createdAt: Time.Posix
  , isBlocked: Bool
  }

view : Event -> Html msg
view event =
  div [] (
    [ text event.name ]
    ++ if event.isBlocked then
        [ span [] [ text "(blocked)" ] ]
      else []
    )
