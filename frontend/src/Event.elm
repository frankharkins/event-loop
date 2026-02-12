module Event exposing (Event, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Keyed
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

view : List Event -> Html msg
view events = Html.Keyed.node "div" [] (
  case events of
      first::rest -> (firstEvent first)::(rest |> List.indexedMap (backlogEvent ((List.length events) - 2)))
      _ -> []
  )

sharedClasses : String
sharedClasses = "w-full p-2 my-2 -mx-2 transition-all rounded-[4px] transform-gpu border-1 border-transparent hover:border-muted-extra"

firstEvent : Event -> (String, Html msg)
firstEvent event =
  let
    instruction = if event.isBlocked then "Is this still blocked?" else "You're working on..."
  in
    ("Don't remount me"
    , Html.Keyed.node "div" [ class "my-[3lh]" ]
      [ ("keep me", div [] [ text instruction ])
      , (event.id, div [
          class (String.join " "
            [ "p-2 my-0 text-title font-bold animate-main-task flex justify-between"
            , sharedClasses
            , if event.isBlocked then stripedBackground else ""
            ]
          )
        ](
        [ span [ class "bg-bg" ] [ text event.name ] ]
        ++ if event.isBlocked then
            [ span [ class "bg-bg font-normal" ] [ text "(blocked)" ] ]
          else []
        )
        )
     ]
    )

stripedBackground : String
stripedBackground =
  "bg-[repeating-linear-gradient(45deg,transparent,transparent_4px,var(--color-muted-extra)_5px,var(--color-muted-extra)_5px,transparent_6px)]"

backlogEvent : Int -> Int -> Event -> (String, Html msg)
backlogEvent lastItem index event =
  let
    animation = if index == lastItem then
        "animate-float-in"
      else if (modBy 2 index) == 0 then
          "animate-float"
        else "animate-float-2"
    background = if event.isBlocked then
        stripedBackground
      else
        ""
  in
    ( event.id
    , div [ class (String.join " " [background, animation, sharedClasses]) ]
      [ span [ class "flex justify-between" ]
        ([ span [ class "bg-bg" ] [ text event.name ] ]
          ++ if event.isBlocked then [ span [ class "bg-bg" ] [ text "(blocked)" ] ]
             else []
        )
      ]
    )
